def max_of_three(a, b, c):
    if a >= b and a >= c:
        return a
    if b >= c:
        return b
    return c


a = int(input("Enter the first number: "))
b = int(input("Enter the second number: "))
c = int(input("Enter the third number: "))

print("Maximum:", max_of_three(a, b, c))
