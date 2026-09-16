def is_perfect(n):
    if n < 2:
        return False
    total = 0
    for i in range(1, n):
        if n % i == 0:
            total += i
    return total == n


n = int(input("Enter a number: "))

if is_perfect(n):
    print(n, "is a perfect number")
else:
    print(n, "is not a perfect number")
