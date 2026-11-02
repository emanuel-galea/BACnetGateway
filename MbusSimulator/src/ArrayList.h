#ifndef __defined_arraylist_h
#define __defined_arraylist_h

#include <stdlib.h>
#include <stdio.h>

//
///*
//  constants
//*/
//#undef TRUE
//#define TRUE 1
//
//#undef FALSE
//#define FALSE 0
//
//
///*
//  type definitions
//*/
//#undef Boolean
//#define Boolean short unsigned int

#undef Object
#define Object void*

typedef struct Arraylist_Struct *Arraylist;


/*
  function declarations
*/
void arraylist_free(const Arraylist list);
Arraylist arraylist_create(bool (*equals)(const Object object_1, const Object object_2));
bool arraylist_add(const Arraylist list, Object object);
bool arraylist_remove(const Arraylist list, const Object object);
bool arraylist_contains(const Arraylist list, const Object object);
int arraylist_index_of(const Arraylist list, const Object object);
bool arraylist_is_empty(const Arraylist list);
int arraylist_size(const Arraylist list);
Object arraylist_get(const Arraylist list, const int index);
void arraylist_clear(const Arraylist list);
void arraylist_sort(const Arraylist list, const int (*compare)(const Object object_1, const Object object_2));


#endif /* __defined_arraylist_h */

