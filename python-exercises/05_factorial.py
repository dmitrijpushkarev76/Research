def factorial(n):
    if n == 0:
        return 1
    return n * factorial(n - 1)


n = int(input("Enter a non-negative integer: "))

if n < 0:
    print("The number must be non-negative")
else:
    print("Factorial:", factorial(n))
