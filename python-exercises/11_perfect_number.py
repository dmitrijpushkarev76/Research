def is_perfect(n):
    if n < 2:
        return False
    total = 0
    for i in range(1, n):
        if n % i == 0:
            total += i
    return total == n


print(is_perfect(6))
print(is_perfect(28))
print(is_perfect(12))
