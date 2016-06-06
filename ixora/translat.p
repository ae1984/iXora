/* translate.p       
 * MODULE
        Переводы
 * DESCRIPTION
        Переводы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
 * AUTHOR
        16/06/05 Ilchuk
 * CHANGES 
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav
        14/07/08 marinav - ограничение на сумму ( не > 10000)


 */

def input parameter podtv as logical.

{mainhead.i}
 
{sixn2.i 
    &head = "translat"
    &headkey = "nomer"
    &option = "TRANSL"

    &keytype = "string"
    &numsys = "auto"
    &numprg = "xxx"
    &nmbrcode = "translat"
    
    &subprg = "s_translat(podtv)"
    &postadd = "
    "
    &nonew = podtv
}
  

