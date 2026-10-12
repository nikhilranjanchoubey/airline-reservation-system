import urllib.request
import urllib.parse
import re
import hmac
import hashlib
import time

BASE_URL = 'http://localhost:8080/airline-reservation-system'
cookie_jar = urllib.request.HTTPCookieProcessor()
opener = urllib.request.build_opener(cookie_jar)

# 1. Login
login_data = urllib.parse.urlencode({
    'email': 'passenger@airline.com',
    'password': 'Passenger@12345'
}).encode('utf-8')
resp = opener.open(f'{BASE_URL}/login', data=login_data)
assert resp.status == 200

# 2. Book
uid = int(time.time() * 1000) % 100000
post_booking = urllib.parse.urlencode({
    'scheduleId': '1',
    'travelClass': 'Economy',
    'passengersCount': '1',
    'selectedSeats': '',
    'firstName_1': 'Aarav',
    'lastName_1': 'Patel',
    'gender_1': 'MALE',
    'dob_1': '1990-01-01',
    'passport_1': f'P{uid}',
    'nationality_1': 'Indian',
    'type_1': 'ADULT',
    'contactEmail': 'passenger@airline.com',
    'contactPhone': '+919876543210'
}).encode('utf-8')
resp = opener.open(f'{BASE_URL}/book-flight', data=post_booking)
checkout_url = resp.geturl()
print("Checkout URL:", checkout_url)
booking_id = checkout_url.split('bookingId=')[1]
html = resp.read().decode('utf-8')

m_order = re.search(r'"order_id":\s*"([^"]+)"', html)
order_id = m_order.group(1)
print("Order ID:", order_id)
assert order_id.startswith("order_") and not order_id.startswith("order_sim_")

# 3. Simulate client receiving payment_id from Razorpay Checkout modal and submitting verification form
payment_id = 'pay_test_' + order_id.split('_')[1]
secret = 'aXkUG2wzv0STU1qphKmiG07J'
payload = f'{order_id}|{payment_id}'.encode('utf-8')
signature = hmac.new(secret.encode('utf-8'), payload, hashlib.sha256).hexdigest()

verify_data = urllib.parse.urlencode({
    'bookingId': booking_id,
    'razorpay_order_id': order_id,
    'razorpay_payment_id': payment_id,
    'razorpay_signature': signature
}).encode('utf-8')

verify_res = opener.open(f'{BASE_URL}/booking/verify-payment', data=verify_data)
confirm_url = verify_res.geturl()
print("Verify result URL:", confirm_url)
assert '/booking/confirmation' in confirm_url, f"Expected confirmation redirect, got {confirm_url}"

confirm_html = verify_res.read().decode('utf-8')
assert 'Booking Confirmed' in confirm_html or 'CONFIRMED' in confirm_html
print(">>> PAYMENT VERIFIED & BOOKING CONFIRMED SUCCESSFULLY! <<<")
