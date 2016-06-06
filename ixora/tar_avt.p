/* tar_avt.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Авторизация тарифов
 * RUN

 * CALLER
        
 * SCRIPT
        
 * INHERIT
        tar2_ak.p, tar2_b.p
 * MENU
        9-1-2-6-4
 * AUTHOR
        20.08.02 saltanat   Справочник комиссий за услуги /  Справочник комиссий по счетам
 * CHANGES
*/

{global.i}
{yes-no.i}

def new shared var v-stat as char init ''.
def var v-sel as char init ''.

 run sel2 ("Выбор :", " 1. Добавленные | 2. Измененные | 3. Удаленные ", output v-sel).
 
 case v-sel:
    /* ADD */
    when "1" then v-stat = 'n'.
    /* CHANGE */
    when "2" then v-stat = 'c'.
    /* DELETE */
    when "3" then v-stat = 'd'. 
 end.

 run tavt_add.

