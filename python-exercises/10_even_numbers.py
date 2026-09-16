numbers = [int(x) for x in input("Enter numbers separated by spaces: ").split()]
even = []

for n in numbers:
    if n % 2 == 0:
        even.append(n)

print(even)
