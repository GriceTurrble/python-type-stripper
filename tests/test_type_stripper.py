import pytest

from type_stripper import strip_annotations


@pytest.fixture
def input_code() -> str:
    return """def func(
    a: int,
    b: str = "30",
    c: int = 42,
    *args: str,
    **kwargs: dict[str, int],
) -> str:
    return "something"

# Preserve comments!
a: str = "what"
b: int
b = 10

class Foo:
    c: str

    def __init__(self, c: str):
        self.c: str = c
"""


@pytest.fixture
def output_code() -> str:
    return """def func(
    a,
    b = "30",
    c = 42,
    *args,
    **kwargs,
):
    return "something"

# Preserve comments!
a = "what"
b = 10

class Foo:

    def __init__(self, c):
        self.c = c
"""


def test_strips_types(input_code: str, output_code: str):
    result = strip_annotations(code=input_code.strip())
    assert result.strip() == output_code.strip()
