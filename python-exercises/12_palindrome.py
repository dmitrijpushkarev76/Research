def is_palindrome(text):
    text = text.lower().replace(" ", "")
    return text == text[::-1]


print(is_palindrome("madam"))
print(is_palindrome("nurses run"))
print(is_palindrome("python"))
