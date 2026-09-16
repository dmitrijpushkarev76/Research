def multiply_list(numbers):
    result = 1
    for n in numbers:
        result *= n
    return result


print(multiply_list([8, 2, 3, -1, 7]))
