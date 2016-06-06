/* add_temp.i
 * MODULE
        ЋБГҐБ Ї® Є®¤ ¬ ¤®Е®¤®ў/Ю АЕ®¤®ў ®ЇҐЮ ФЁ©
 * DESCRIPTION
        ЋБГҐБ Ї® Є®¤ ¬ ¤®Е®¤®ў/Ю АЕ®¤®ў ®ЇҐЮ ФЁ©
 * RUN
        ‘Ї®А®Ў ўК§®ў  ЇЮ®ёЮ ¬¬К, ®ЇЁА ­ЁҐ Ї Ю ¬ҐБЮ®ў, ЇЮЁ¬ҐЮК ўК§®ў 
 * CALLER
        ‘ЇЁА®Є ЇЮ®ФҐ¤ЦЮ, ўК§Кў НИЁЕ МБ®Б Д ©«
 * SCRIPT
        ‘ЇЁА®Є АЄЮЁЇБ®ў, ўК§Кў НИЁЕ МБ®Б Д ©«
 * INHERIT
        codsdat.p
 * MENU
        8-7-3-12
 * AUTHOR
        04/02/06 nataly
 * CHANGES
        22.06.2006 nataly ЎК« ¤®ў ў«Ґ­  ®ЎЮ Ў®БЄ  АЄ« ¤ , ЏЮЁ«®¦ 12,13,14.
*/
     create {&tmp}.
       assign 
        {&tmp}.tn   = ""
        {&tmp}.name = ""
        {&tmp}.rnn  = ""
        {&tmp}.dep  = codfr.name[3]
        {&tmp}.depname = codfr.name[1]
        {&tmp}.post   = ""
        {&tmp}.tottndep = 1
        {&tmp}.tottn = 0
        {&tmp}.mon   = month(t-cods.jdt). 
