def count_case(text):
    upper = 0
    lower = 0
    for ch in text:
        if ch.isupper():
            upper += 1
        elif ch.islower():
            lower += 1
    return upper, lower


text = input("Enter a string: ")
upper, lower = count_case(text)

print("No. of Upper case characters :", upper)
print("No. of Lower case Characters :", lower)
