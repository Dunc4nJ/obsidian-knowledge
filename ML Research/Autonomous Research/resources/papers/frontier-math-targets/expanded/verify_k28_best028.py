#!/usr/bin/env python3
"""Exact verifier for Aichholzer's archived K28 point construction."""

from __future__ import annotations

import argparse
import hashlib
import itertools
from pathlib import Path


Point = tuple[int, int]
EXPECTED_SHA256 = "666d74d36b125e18e439167918bc150f1e82bbb3db5c99ab568021b7c9bfa6fa"


def orient(a: Point, b: Point, c: Point) -> int:
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def proper_crossing(a: Point, b: Point, c: Point, d: Point) -> bool:
    return orient(a, b, c) * orient(a, b, d) < 0 and orient(c, d, a) * orient(c, d, b) < 0


def load_points(raw: bytes) -> list[Point]:
    rows = raw.decode("ascii").splitlines()
    expected = int(rows[0])
    points: list[Point] = []
    for line_number, row in enumerate(rows[1:], start=2):
        if not row.strip():
            continue
        fields = row.split()
        if len(fields) != 2:
            raise ValueError(f"line {line_number} has {len(fields)} fields rather than two")
        x, y = map(int, fields)
        points.append((x, y))
    if len(points) != expected:
        raise ValueError(f"header declares {expected} points but file contains {len(points)}")
    if len(set(points)) != len(points):
        raise ValueError("duplicate points")
    return points


def verify(points: list[Point]) -> tuple[int, int, int]:
    triples = 0
    for a, b, c in itertools.combinations(points, 3):
        triples += 1
        if orient(a, b, c) == 0:
            raise ValueError(f"collinear triple: {a}, {b}, {c}")

    crossings = 0
    quadruples = 0
    for a, b, c, d in itertools.combinations(points, 4):
        quadruples += 1
        matches = (
            proper_crossing(a, b, c, d),
            proper_crossing(a, c, b, d),
            proper_crossing(a, d, b, c),
        )
        crossing_count = sum(matches)
        if crossing_count > 1:
            raise AssertionError(f"four points produced {crossing_count} proper crossings")
        crossings += crossing_count
    return triples, quadruples, crossings


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("path", nargs="?", type=Path, default=Path(__file__).with_name("k28-best028.asc"))
    args = parser.parse_args()

    raw = args.path.read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    if digest != EXPECTED_SHA256:
        raise ValueError(f"artifact SHA-256 {digest} does not match pinned source {EXPECTED_SHA256}")
    points = load_points(raw)
    triples, quadruples, crossings = verify(points)
    print(f"artifact={args.path}")
    print(f"sha256={digest}")
    print(f"points={len(points)}")
    print(f"triples_checked={triples}")
    print("general_position=true")
    print(f"quadruples_checked={quadruples}")
    print(f"crossings={crossings}")
    verified = len(points) == 28 and crossings == 7234
    print(f"verified={str(verified).lower()}")
    if not verified:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
