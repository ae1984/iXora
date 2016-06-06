/* r-translate.p          
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
        19/06/05 Ilchuk
 * CHANGES 
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav


 */

def input parameter podtv as logical.
{mainhead.i}
 
{sixn2.i 
    &head = "r-translat"
    &headkey = "nomer"
    &option = "TRANSL"

    &keytype = "string"
    &numsys = "auto"
    &numprg = "xxx"
    &nmbrcode = "r-translat"
    
    &subprg = "s_r-translat(podtv)"
    &postadd = " "
    &nonew = "true"
}
