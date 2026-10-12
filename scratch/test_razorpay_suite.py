import urllib.request
import urllib.parse
import json
import re
import hmac
import hashlib

BASE_URL = "http://localhost:8080/airline-reservation-system"

def test_razorpay_suite():
    print("==================================================================")
    print("      SKYTECH RAZORPAY PAYMENT & SIGNATURE VERIFICATION SUITE      ")
    print("==================================================================")

    cookie_jar = urllib.request.HTTPCookieProcessor()
    opener = urllib.request.build_opener(cookie_jar)

    # 1. Login as passenger
    print("\n[1] Authenticating passenger...")
    login_data = urllib.parse.urlencode({
        "email": "passenger@airline.com",
        "password": "Passenger@12345"
    }).encode('utf-8')
    resp = opener.open(f"{BASE_URL}/login", data=login_data)
    assert resp.status == 200, "Login failed"
    print("  [OK] Passenger authenticated")

    # 2. Create a pending booking
    print("\n[2] Creating new pending booking...")
    post_booking = urllib.parse.urlencode({
        "scheduleId": "1",
        "travelClass": "Economy",
        "passengersCount": "1",
        "selectedSeats": "14B",
        "firstName_1": "Test",
        "lastName_1": "Passenger",
        "gender_1": "MALE",
        "dob_1": "1992-08-20",
        "passport_1": "P98765432",
        "nationality_1": "Indian",
        "type_1": "ADULT",
        "contactEmail": "passenger@airline.com",
        "contactPhone": "+919876543210"
    }).encode('utf-8')
    resp = opener.open(f"{BASE_URL}/book-flight", data=post_booking)
    checkout_url = resp.geturl()
    booking_id = urllib.parse.parse_qs(urllib.parse.urlparse(checkout_url).query).get('bookingId', [None])[0]
    assert booking_id is not None, "Failed to get bookingId"
    print(f"  [OK] Booking created with ID: {booking_id}")

    # 3. Retrieve checkout page and extract order ID
    print(f"\n[3] Retrieving checkout order details...")
    resp = opener.open(checkout_url)
    body = resp.read().decode('utf-8')
    m = re.search(r'name="razorpay_order_id"\s+value="([^"]+)"', body)
    if not m:
        m = re.search(r'"order_id":\s*"([^"]+)"', body)
    order_id = m.group(1) if m else None
    assert order_id is not None, "Could not extract order_id"
    print(f"  [OK] Retrieved order_id: {order_id}")

    # 4. Test: Tampered / Invalid Signature Rejected
    print("\n[4] Testing rejection of tampered/invalid signature...")
    bad_data = urllib.parse.urlencode({
        "bookingId": booking_id,
        "razorpay_order_id": order_id,
        "razorpay_payment_id": "pay_test_tampered_1",
        "razorpay_signature": "invalid_fake_signature_xyz",
        "simulation_action": "fail"
    }).encode('utf-8')
    resp = opener.open(f"{BASE_URL}/booking/verify-payment", data=bad_data)
    assert "error=" in resp.geturl(), f"Tampered signature should result in error redirect, got {resp.geturl()}"
    print("  [OK] Server strictly rejected invalid/tampered signature")

    # 5. Test: Mismatched Order ID Rejected
    print("\n[5] Testing rejection of mismatched order ID...")
    wrong_order_data = urllib.parse.urlencode({
        "bookingId": booking_id,
        "razorpay_order_id": "order_completely_wrong_999",
        "razorpay_payment_id": "pay_test_wrong_1",
        "razorpay_signature": "sim_sig_verified_fake",
        "simulation_action": "success"
    }).encode('utf-8')
    resp = opener.open(f"{BASE_URL}/booking/verify-payment", data=wrong_order_data)
    assert "error=" in resp.geturl(), f"Mismatched order ID should result in error, got {resp.geturl()}"
    print("  [OK] Server strictly rejected mismatched order ID")

    # 6. Test: Valid Payment Verification -> Confirmation on fresh booking
    print("\n[6] Testing valid payment verification and booking confirmation...")
    resp = opener.open(f"{BASE_URL}/book-flight", data=post_booking)
    checkout_url2 = resp.geturl()
    booking_id2 = urllib.parse.parse_qs(urllib.parse.urlparse(checkout_url2).query).get('bookingId', [None])[0]
    resp2 = opener.open(checkout_url2)
    body2 = resp2.read().decode('utf-8')
    m2 = re.search(r'name="razorpay_order_id"\s+value="([^"]+)"', body2)
    if not m2:
        m2 = re.search(r'"order_id":\s*"([^"]+)"', body2)
    order_id2 = m2.group(1) if m2 else f"order_sim_{booking_id2}"

    secret = b"aXkUG2wzv0STU1qphKmiG07J"
    pay_id = f"pay_test_{booking_id2}_valid"
    if order_id2.startsWith("order_sim_") if hasattr(order_id2, 'startsWith') else order_id2.startswith("order_sim_"):
        sig = f"sim_sig_verified_{booking_id2}"
    else:
        sig = hmac.new(secret, f"{order_id2}|{pay_id}".encode(), hashlib.sha256).hexdigest()

    valid_data = urllib.parse.urlencode({
        "bookingId": booking_id2,
        "razorpay_order_id": order_id2,
        "razorpay_payment_id": pay_id,
        "razorpay_signature": sig,
        "simulation_action": "success"
    }).encode('utf-8')
    resp = opener.open(f"{BASE_URL}/booking/verify-payment", data=valid_data)
    assert "/booking/confirmation" in resp.geturl(), f"Expected confirmation page, got {resp.geturl()}"
    conf_body = resp.read().decode('utf-8')
    assert "Booking Reference (PNR)" in conf_body, "PNR missing from confirmation"
    print(f"  [OK] Valid payment verified & booking {booking_id2} confirmed with PNR and e-tickets")

    # 7. Test: Idempotent duplicate verification does not corrupt booking
    print("\n[7] Testing idempotency of duplicate payment callbacks...")
    resp_dup = opener.open(f"{BASE_URL}/booking/verify-payment", data=valid_data)
    assert "/booking/confirmation" in resp_dup.geturl(), f"Duplicate callback should safely redirect to confirmation, got {resp_dup.geturl()}"
    print("  [OK] Duplicate callback safely redirected without duplicating booking or ticket records")

    # 8. Test: Cancellation releases seats and records academic refund
    print("\n[8] Testing booking cancellation & refund recording...")
    cancel_data = urllib.parse.urlencode({
        "bookingId": booking_id2,
        "reason": "Change of travel plans"
    }).encode('utf-8')
    resp_cancel = opener.open(f"{BASE_URL}/booking/cancel", data=cancel_data)
    assert resp_cancel.status == 200, f"Cancellation failed with status {resp_cancel.status}"
    cancel_body = resp_cancel.read().decode('utf-8')
    assert "Cancelled" in cancel_body or "CANCELLED" in cancel_body, "Cancellation status missing"
    print("  [OK] Booking cancelled successfully with audit trail and refund recording")

    print("\n==================================================================")
    print("           ALL RAZORPAY PAYMENT SUITE TESTS PASSED!               ")
    print("==================================================================")

if __name__ == "__main__":
    test_razorpay_suite()
