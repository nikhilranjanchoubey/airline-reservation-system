import urllib.request
import urllib.parse
import re
import time

BASE_URL = 'http://localhost:8080/airline-reservation-system'
cookie_jar = urllib.request.HTTPCookieProcessor()
opener = urllib.request.build_opener(cookie_jar)

# 1. Login
print("Step 1: Authenticating passenger...")
login_data = urllib.parse.urlencode({
    'email': 'passenger@airline.com',
    'password': 'Passenger@12345'
}).encode('utf-8')
resp = opener.open(f'{BASE_URL}/login', data=login_data)
assert resp.status == 200, f"Login failed: status {resp.status}"
print("  [OK] Passenger authenticated")

# 2. Book with auto-allocated / unique seat
print("\nStep 2: Submitting booking to reach checkout...")
unique_suffix = int(time.time()) % 1000
post_booking = urllib.parse.urlencode({
    'scheduleId': '1',
    'travelClass': 'Economy',
    'passengersCount': '1',
    'selectedSeats': '', # Auto-allocated
    'firstName_1': 'Rahul',
    'lastName_1': 'Sharma',
    'gender_1': 'MALE',
    'dob_1': '1995-04-12',
    'passport_1': f'P{unique_suffix}4321',
    'nationality_1': 'Indian',
    'type_1': 'ADULT',
    'contactEmail': 'passenger@airline.com',
    'contactPhone': '+919876543210'
}).encode('utf-8')
resp = opener.open(f'{BASE_URL}/book-flight', data=post_booking)
checkout_url = resp.geturl()
print(f"  [OK] Reached checkout: {checkout_url}")
assert '/booking/checkout' in checkout_url, f"FAIL: Expected redirect to checkout, got: {checkout_url}"

# 3. Inspect Checkout Page
print("\nStep 3: Inspecting checkout page HTML...")
resp = opener.open(checkout_url)
html = resp.read().decode('utf-8')

m_order = re.search(r'"order_id":\s*"([^"]+)"', html)
if not m_order:
    m_order = re.search(r'name="razorpay_order_id"\s+value="([^"]+)"', html)
order_id = m_order.group(1) if m_order else None

m_key = re.search(r'"key":\s*"([^"]+)"', html)
key_id = m_key.group(1) if m_key else None

print(f"  Extracted Order ID: {order_id}")
print(f"  Extracted Key ID: {key_id}")

is_real_razorpay = (order_id is not None) and order_id.startswith('order_') and (not order_id.startswith('order_sim_'))
has_sim_button = 'Simulate Successful Payment' in html
has_subtle_test_mode = 'Test Mode' in html
has_razorpay_checkout_js = 'checkout.razorpay.com/v1/checkout.js' in html
has_yellow_banner_text = 'Razorpay Sandbox Active • Test Mode' in html
has_yellow_banner_text2 = 'Razorpay Sandbox Active &bull; Test Mode' in html
has_yellow_alert_class = 'alert-warning' in html

print(f"  Is Real Razorpay Order? {is_real_razorpay}")
print(f"  Has Simulation Button? {has_sim_button}")
print(f"  Has Subtle Test Mode Label? {has_subtle_test_mode}")
print(f"  Has Razorpay checkout.js? {has_razorpay_checkout_js}")
print(f"  Has Yellow Banner (Text)? {has_yellow_banner_text or has_yellow_banner_text2}")
print(f"  Has Yellow Alert Class? {has_yellow_alert_class}")

assert is_real_razorpay, f"FAIL: Expected real Razorpay order ID starting with 'order_', but got: {order_id}"
assert not has_sim_button, "FAIL: Page still contains simulation button"
assert has_razorpay_checkout_js, "FAIL: Page missing official checkout.js"
assert key_id == "rzp_test_TV8dPCYpmBNuf0", f"FAIL: Incorrect key ID: {key_id}"
assert not has_yellow_banner_text, "FAIL: Large yellow banner text still present!"
assert not has_yellow_banner_text2, "FAIL: Large yellow banner text still present!"
assert not has_yellow_alert_class, "FAIL: alert-warning yellow banner container still present!"

# Check for SkyTech tokens
has_sky_navy = '--sky-navy' in html
has_manrope = 'Manrope' in html
has_inter = 'Inter' in html
has_stepper = 'sky-stepper' in html
has_summary_card = 'Booking Summary' in html

print(f"  Contains SkyTech design tokens? {has_sky_navy}")
print(f"  Contains Manrope & Inter fonts? {has_manrope and has_inter}")
print(f"  Contains 4-step progress tracker? {has_stepper}")
print(f"  Contains Booking Summary? {has_summary_card}")

assert has_sky_navy, "FAIL: Missing --sky-navy design token"
assert has_manrope, "FAIL: Missing Manrope font"
assert has_inter, "FAIL: Missing Inter font"
assert has_stepper, "FAIL: Missing 4-step progress tracker"
assert has_summary_card, "FAIL: Missing Booking Summary card"

print("\n>>> ALL CHECKOUT IMPROVEMENT VERIFICATION CHECKS PASSED SUCCESSFULLY! <<<")
