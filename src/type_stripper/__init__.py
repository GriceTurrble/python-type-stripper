"""type-stripper module."""

from pathlib import Path
from typing import Union

import click
import libcst as cst


class TypeStripperTransformer(cst.CSTTransformer):
    """CST transformer to strip type annotations from the tree."""

    def leave_FunctionDef(  # noqa: N802 (invalid-function-name)
        self,
        original_node: cst.FunctionDef,
        updated_node: cst.FunctionDef,
    ) -> cst.FunctionDef:
        """Modifies a function definition to strip its return annotations."""
        return updated_node.with_changes(
            returns=None,
        )

    def leave_Param(  # noqa: N802 (invalid-function-name)
        self,
        original_node: cst.Param,
        updated_node: cst.Param,
    ) -> cst.Param:
        """Modifies a function parameter to remove its type annotations."""
        return updated_node.with_changes(
            annotation=None,
        )

    def leave_AnnAssign(  # noqa: N802 (invalid-function-name)
        self,
        original_node: cst.AnnAssign,
        updated_node: cst.AnnAssign,
    ) -> Union[cst.Assign, cst.RemovalSentinel]:
        """Transform an annotated assignment to a simple assignment if possible.

        Bare annotations like `x: int` are removed from the tree entirely.
        """
        if updated_node.value is None:
            # This is a bare annotated assign, like `x: int`.
            # We do not need this in the tree at all.
            return cst.RemoveFromParent()
        return cst.Assign(
            targets=[cst.AssignTarget(target=updated_node.target)],
            value=updated_node.value,
        )


def strip_annotations(code: str) -> str:
    """Parses 'code' strips type annotations, and returns the modified code."""
    tree = cst.parse_module(source=code)
    modified = tree.visit(visitor=TypeStripperTransformer())
    # Throw a .strip() on the end to remove extra newlines resulting from node removals
    return modified.code.strip()


@click.command()
@click.argument(
    "file",
    type=click.Path(
        exists=True,
        dir_okay=False,
        path_type=Path,
    ),
)
def main(file: Path) -> None:
    """Entrypoint for type-stripper.

    Takes a 'file' Path and prints the modified source code to stdout.
    """
    print(strip_annotations(file.read_text()))  # pragma: nocover


if __name__ == "__main__":
    main()  # pragma: nocover
