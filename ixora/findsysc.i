/* findsysc.i
 * MODULE
        Ќ §ў ­ЁҐ ЏЮ®ёЮ ¬¬­®ё® Њ®¤Ц«О
 * DESCRIPTION
        Ќ §­ ГҐ­ЁҐ ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ ЇЮ®ФҐ¤ЦЮ Ё ДЦ­ЄФЁ©
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
        29/09/04 isaev
 * CHANGES
        18.10.2004 isaev    - 3 Ї Ю ¬ҐБЮ - БЁЇ SYSC
        06.12.2004 isaev    - 4 Ї Ю ¬ҐБЮ - ¤Ґ©АБўЁҐ
        10.12.2004 isaev    - 5 Ї Ю ¬ҐБЮ - ­ҐЮЦё БЛАО
 */


/*
 {1} Ё¬О SYSC
 {2} ЇҐЮ¬Ґ­­ О
 {3} Ї®«Ґ SYSC (chval, inval, daval, loval)
 {4} ¤Ґ©АБўЁҐ ў А«ЦГ Ґ Є®ё¤  SYSC ­Ґ ­ ©¤Ґ­ 
     (ҐА«Ё "def" Ё«Ё ЇЦАБ О АБЮ®Є , Б® ўКЕ®¤ Ё§ БҐЄЦИҐ© ЇЮ®ФҐ¤ЦЮК)
 {5} ҐА«Ё ­ҐЇЦАБ® - Б® ­Ґ ЮЦё БЛАО
 */

find first sysc where sysc.sysc = '{1}' no-lock no-error.
if not avail sysc then do:
    if "{5}" = "" then do:
        unix silent value('echo `date` There is no record {1} in SYSC file!').
        v-text = 'There is no record {1} in SYSC file!'.
        run lgps.
    end.
    if "{4}" = "" or "{4}" = "default" then 
        return.
    {4}.
end.
else {2} = sysc.{3}.

