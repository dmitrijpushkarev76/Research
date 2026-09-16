def unique_list(items):
    result = []
    for item in items:
        if item not in result:
            result.append(item)
    return result


print(unique_list([1, 2, 3, 3, 3, 3, 4, 5]))
