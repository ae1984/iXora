/* minnine1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        26/08/05 ten
 * CHANGES
*/


def  shared var a1 as dec.

def shared temp-table temp
    field dday as char
    field ddate as date
    field out as dec
    field summ as dec
    field raz as dec
    field adate as char
    field oui as dec
    field outi as dec
    field prim as dec
    field teng as decimal
    field nrt as dec
    field nra as dec
    field gold as decimal
    field aweek as char
    field obz as dec
    field forf as dec
    field dumpi as dec
    field dumpd as dec
    field dumpdi as dec
    field vali as dec
    field vald as dec
    field valdi as dec
    field tr as dec
    field fr as dec
    field fv as dec
    field nn as dec
    field el as dec
    field tn as dec
    field week as int.


def var v-gl as char.
def temp-table tempgl
    field gl as integer
    field gdt like ast.glday.gdt.


def input parameter v-start as date.
def input parameter v-close as date.

for each ast.gl  where ast.gl.totlev = 1 no-lock.
  v-gl = substr(string(ast.gl.gl),1,4).
  if (v-gl = '2203' or v-gl = '2204' or v-gl = '2205' or v-gl = '2209' or v-gl = '2211' or v-gl = '2221') then do:
     create tempgl.
            tempgl.gl = ast.gl.gl.
end.
end.

for each temp.
         temp.tr = 0.
         temp.fr = 0.
         temp.fv = 0.
         temp.nn = 0.
         temp.el = 0.
         temp.tn = 0.
end.
for each temp where temp.ddate >= v-start and temp.ddate <= v-close no-lock.
         temp.raz = temp.raz + temp.summ.
 
    find last ast.glday where ast.glday.gdt <= temp.ddate and ast.glday.gl = 110100  and ast.glday.crc = 1 no-lock no-error.
           if avail ast.glday then     
                if avail ast.crchis then do:    
                   temp.vali =  ast.glday.cam.
                   temp.vald =  ast.glday.dam.
                   temp.valdi = temp.vald - temp.vali.
                end.
                temp.out = temp.valdi.
/*  
for each tempgl .
for each ast.crc no-lock.

find last  ast.glday where ast.glday.gl = tempgl.gl and ast.glday.gdt <= temp.ddate and ast.glday.crc = ast.crc.crc no-lock no-error. 
     if avail ast.glday then   
     find last ast.crchis where ast.crchis.crc = ast.glday.crc and ast.crchis.regdt <=
                        temp.ddate no-lock no-error.
           if avail ast.crchis then do:
             temp.dumpi = ast.glday.cam * ast.crchis.rate[1].
             temp.dumpd = ast.glday.dam * ast.crchis.rate[1].
             temp.dumpdi = (round((temp.dumpi / 1000 ),00) * 100 ) - (round((temp.dumpd / 1000 ),00) * 100). 
             temp.obz = temp.obz + temp.dumpdi.

end. 
end.
end.
*/
end.
