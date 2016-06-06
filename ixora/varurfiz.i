/* varurfiz.i
 * MODULE
        Название модуля - Внутрибанковские операции.
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - ccdb.p,ccdb1.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK
 * CHANGES
        16.08.2012 damir - добавил новые переменные.
        05.02.2012 damir - Перекомпиляция.
        19/09/2013 Luiza  - ТЗ 1945 добавление счета 2213
*/
def {1} shared temp-table t-cif
    field city as char
	field cif as char
	field name as char
	field code as char
    field type as char
    field i2203 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2204 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2205 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2206 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2207 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2213 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2215 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2217 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2013 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2123 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2124 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2219 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2223 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2240 as deci format "zzz,zzz,zzz,zz9.99-"
    field i2237 as deci format "zzz,zzz,zzz,zz9.99-"
    field sum as deci format "zzz,zzz,zzz,zz9.99-"
index sum is primary sum descending
index idx2 cif ascending.

def {1} shared var v-type as char no-undo.
def {1} shared var v-dt as date no-undo.
def {1} shared var v-repnum as inte no-undo.
def {1} shared var v-urfiz as logi init no.

def {1} shared var s_ur_i2203 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2204 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2205 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2206 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2207 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2213 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2215 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2217 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2013 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2123 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2124 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2219 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2223 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2240 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_ur_i2237 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.

def {1} shared var s_fiz_i2203 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2204 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2205 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2206 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2207 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2213 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2215 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2217 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2013 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2123 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2124 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2240 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_fiz_i2237 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.

def {1} shared var f10_ur_i2203 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2204 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2205 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2206 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2207 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2213 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2215 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2217 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2013 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2123 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2124 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2219 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2223 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2240 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_ur_i2237 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.

def {1} shared var f10_fiz_i2203 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2204 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2205 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2206 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2207 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2213 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2215 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2217 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2013 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2123 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2124 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2240 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_fiz_i2237 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.

def {1} shared var f20_ur_i2203 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2204 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2205 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2206 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2207 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2213 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2215 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2217 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2013 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2123 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2124 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2219 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2223 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2240 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_ur_i2237 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.

def {1} shared var f20_fiz_i2203 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2204 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2205 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2206 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2207 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2213 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2215 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2217 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2013 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2123 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2124 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2240 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_fiz_i2237 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.

def {1} shared var s_i2203 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2204 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2205 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2206 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2207 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2213 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2215 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2217 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2013 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2123 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2124 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2219 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2223 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2240 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var s_i2237 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.

def {1} shared var f10_i2203 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2204 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2205 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2206 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2207 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2213 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2215 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2217 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2013 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2123 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2124 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2219 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2223 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2240 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f10_i2237 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.

def {1} shared var f20_i2203 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2204 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2205 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2206 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2207 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2213 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2215 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2217 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2013 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2123 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2124 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2219 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2223 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2240 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.
def {1} shared var f20_i2237 as deci format "zzz,zzz,zzz,zz9.99-" no-undo.