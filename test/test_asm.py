import unittest
from src import abasm

class Example(unittest.TestCase):
    
    def test_check(self):
        self.assertEqual(5, 10, "number does not match")

if __name__ == "__main__":
    unittest.main()
