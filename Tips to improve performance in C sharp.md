Tips to improve performance in C sharp.md

1. Reduce loop

    1.1 Merge 2 loops into 1 by using 2 fields for index. Example: aPosition, bPosition

    1.2 Use hashtable to reduce loop

2. Optimize time by type

    2.1 `for` loop will be faster than `foreach`

    2.2 `struct` will be faster than `class`

    2.3 `StringBuilder` will be faster than `string combination`

    2.4 `Array` will be faster than `List<T>`

    2.5 `Field` will faster than `Property`