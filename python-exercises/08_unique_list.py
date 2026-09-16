def unique_list(items):
    result = []
    for item in items:
        if item not in result:
            result.append(item)
    return result


items = [int(x) for x in input("Enter numbers separated by spaces: ").split()]

print("Unique list:", unique_list(items))
