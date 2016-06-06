/* dirsend.p
 * MODULE
        ЏЮО¬КҐ Є®ЮЮҐАЇ®­¤Ґ­БАЄЁҐ ®Б­®ХҐ­ЁО А ¤ЮЦёЁ¬Ё Ў ­Є ¬Ё
 * DESCRIPTION
        ЋГЁАБЄ  Д ©«®ў ў Home - ®БЇЮ ўЁБҐ«О
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        ‘ЇЁА®Є ЇЮ®ФҐ¤ЦЮ, ўК§Кў НИЁЕ МБ®Б Д ©«
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        ‘ЇЁА®Є ўК§Кў Ґ¬КЕ ЇЮ®ФҐ¤ЦЮ
 * MENU
        ЏҐЮҐГҐ­Л ЇЦ­ЄБ®ў ЊҐ­Н ЏЮ ё¬К 
 * AUTHOR
        12/08/2005 kanat
 * CHANGES
*/

def input parameter v-ext1 as character.
def var v-resultd as integer.

input through value ("rm -f *" + v-ext1). 
repeat:
  import v-resultd.
end.

