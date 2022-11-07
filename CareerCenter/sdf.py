def gen_clientid(start=1_000_000, stop=1_999_999):
    from random import randint
    return randint(start, stop)


def gen_managerid(start=2_000, stop=2_999):
    from random import randint
    return randint(start, stop)


if __name__ == "__main__":
    print(gen_clientid())
    print(gen_managerid())
