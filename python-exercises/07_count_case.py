def count_case(text):
    upper = 0
    lower = 0
    for ch in text:
        if ch.isupper():
            upper += 1
        elif ch.islower():
            lower += 1
    return upper, lower


upper, lower = count_case("The quick Brow Fox")
print("No. of Upper case characters :", upper)
print("No. of Lower case Characters :", lower)
