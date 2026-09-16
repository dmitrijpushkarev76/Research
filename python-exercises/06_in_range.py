def in_range(number, start, end):
    if start <= number <= end:
        return True
    return False


number = int(input("Enter a number: "))
start = int(input("Enter the start of the range: "))
end = int(input("Enter the end of the range: "))

if in_range(number, start, end):
    print(number, "is in the range")
else:
    print(number, "is outside the range")
