def in_range(number, start, end):
    if start <= number <= end:
        return True
    return False


print(in_range(5, 1, 10))
print(in_range(15, 1, 10))
