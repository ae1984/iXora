/* vcpartn.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Редактирование справочника инопартнеров - поиск/новый
 * RUN

 * CALLER
        Главное меню
 * SCRIPT

 * INHERIT

 * MENU
        15-6-4, 15-7-1
 * AUTHOR
        18.10.2002 nadejda
 * CHANGES
        28.04.2008 galina - перекомпеляция в связи с изменениями во фрейме vcpartners
        30.0.2008 galina -  исправлено наименование поля info[2]
        02.07.2008 galina - перекомпеляция в связи с изменениями формы vcpartners
        07/10/2010 aigul - перекомпеляция в связи с изменениями формы vcpartners.f
*/


{vc.i}

{mainhead.i}

def new shared var s-newpartner as logical.

{comm-txb.i}
def new shared var s-vcourbank as char.
s-vcourbank = comm-txb().

s-newpartner = false.

{sixn.i
 &head = vcpartners
 &headkey = partner
 &option = VCPARTN
 &numsys = prog
 &keytype = string
 &numprg = vcpartnn
 &subprg = vcpartns.p
 &postadd = "
   vcpartners.rdt = g-today.
   vcpartners.rwho = g-ofc.
   vcpartners.udt = g-today.
   vcpartners.uwho = g-ofc."
}

for each vcpartners where vcpartners.name = '' and vcpartners.cwho = '' and vcpartners.rwho = g-ofc . delete vcpartners. end.


