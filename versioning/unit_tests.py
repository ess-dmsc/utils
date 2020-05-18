#!/usr/bin/env python3

import pytest
import create_release as cr


# unit test
def test_version_from_string():
    assert cr.version_from_string("") == [0, 0, 0]
    assert cr.version_from_string("vffdf") == [0, 0, 0]
    assert cr.version_from_string("v1.1.1") == [1, 1, 1]
    assert cr.version_from_string("v999.9999.99999") == [999, 9999, 99999]
    assert cr.version_from_string("999.9999.99999") == [999, 9999, 99999]
    assert cr.version_from_string("r999.9999.99999") == [0, 0, 0]


# unit test
def test_bump_version():
    for i in range(200):
        for j in range(200):
            assert cr.bump_version([i,j,0], 'major')[0] == '{}.{}.{}'.format(i+1, 0, 0)
            assert cr.bump_version([1,i,j], 'major')[0] == '2.0.0'
            assert cr.bump_version([i,j,0], 'minor')[0] == '{}.{}.{}'.format(i, j + 1, 0)
            assert cr.bump_version([2,i,j], 'minor')[0] == '{}.{}.{}'.format(2, i + 1, 0)
            assert cr.bump_version([3,i,j], 'patch')[0] == '{}.{}.{}'.format(3, i    , j + 1)


# unit test - list of tags (valid and invalid versions)
def test_latest_ver_from_list():
    assert cr.latest_ver_from_list('my_tag a.b.c        gylle') == [0, 0, 0]
    assert cr.latest_ver_from_list('v0.0.0    va.b.c   gylle v3.2.1') == [3, 2, 1]

    assert cr.latest_ver_from_list('v0.0.0  v1.2.3  v3.2.1') == [3, 2, 1]
    assert cr.latest_ver_from_list('v3.2.1  v1.2.3  v3.2.0') == [3, 2, 1]
    assert cr.latest_ver_from_list('v1.2.40 v1.2.30  v1.2.10') == [1, 2, 40]
    assert cr.latest_ver_from_list('v1.4.10 v1.3.10  v1.2.80') == [1, 4, 10]
    assert cr.latest_ver_from_list('v200.3.10  v300.4.10  v100.2.80') == [300, 4, 10]


#
if __name__ == '__main__':
    print("to run the unit tests type")
    print("> pytest unit_test.py")
