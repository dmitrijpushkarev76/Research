def multiply_list(numbers):
    result = 1
    for n in numbers:
        result *= n
    return result


numbers = [int(x) for x in input("Enter numbers separated by spaces: ").split()]

print("Product:", multiply_list(numbers))
