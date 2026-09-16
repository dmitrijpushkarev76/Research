def sum_list(numbers):
    total = 0
    for n in numbers:
        total += n
    return total


numbers = [int(x) for x in input("Enter numbers separated by spaces: ").split()]

print("Sum:", sum_list(numbers))
