<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: https://mayankjoshi.dev');
header('Access-Control-Allow-Methods: POST');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed.']);
    exit;
}

// Honeypot: bots fill hidden fields, humans don't. Reject if non-empty.
// The frontend hides this field with CSS (position:absolute;left:-9999px), NOT display:none.
if (!empty($_POST['hp'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Spam detected.']);
    exit;
}

$name    = htmlspecialchars(strip_tags(trim($_POST['name']    ?? '')));
$email   = filter_var(trim($_POST['email'] ?? ''), FILTER_VALIDATE_EMAIL);
$subject = htmlspecialchars(strip_tags(trim($_POST['subject'] ?? '')));
$message = htmlspecialchars(strip_tags(trim($_POST['message'] ?? '')));

if (!$name || !$email || !$subject || !$message) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'All fields are required.']);
    exit;
}

$to      = 'consciousmayank@gmail.com';
$headers = implode("\r\n", [
    "From: $name <$email>",
    "Reply-To: $email",
    "Content-Type: text/plain; charset=UTF-8",
    "X-Mailer: PHP/" . phpversion(),
]);
$body = "Name: $name\nEmail: $email\nSubject: $subject\n\nMessage:\n$message";

if (mail($to, $subject, $body, $headers)) {
    echo json_encode(['success' => true, 'message' => 'Your message was sent successfully!']);
} else {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Mail failed. Please email consciousmayank@gmail.com directly.']);
}
?>
