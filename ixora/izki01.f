/* izki01.f
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
        31/12/99 pragma
 * CHANGES
*/

form
    header
    "KredЁtiest–des nosaukums"
    "MёneЅa bilances p–rskata" to 200
    skip

    g-comp
    year(dames) format "9999" at 86 space(0) '.gada "' day(dames) format "99."
    '"' men-n[month(dames)]
    "Pielikuma A-1 atЅifrёjums" to 200
    skip(1)

    "KredЁtiest–des kods |_|_|_|"
    "A1-" at 78 space(0) v-col0 format "9" space(0)
    ".PrasЁbas pret iekЅzemes kredЁtiest–dёm"
    v-h1[v-col0] to 200  format "x(30)"
    skip

    "Bilances p–rskata pozЁciju 0321.,0322.,0323.,0324."
    at 71
    /* v-col0 */ i format "9" space(0) ".aile"
    "Veselos latos" at 170
    "A1-" to 199 /* v-col0 */ i1 format "9"

    skip

    fill("-",202) format "x(202)"

/*    12345678901234567890123456789012345678901234567890    */
    "|                                                  |" space(0)
    "  KredЁt-" space(0)
    "|      J–sa‡em      " space(0)
    "|                   " space(0)
    "  ar sa‡emЅanas note" space(0)
    "ikto termi‡u        " space(0)
    "                    " space(0)
    "                    " space(0)
    "|       Kop–        |" space(0)
    skip
    "|              KredЁtiest–des nosaukums            |" space(0)
    " iest–des" space(0)
    "|     ik dienas     " space(0)
    "|-------------------" space(0)
    "--------------------" space(0)
    "--------------------" space(0)
    "--------------------" space(0)
    "--------------------" space(0)
    "|      (01+02+      |" space(0)
    skip


    "|                                                  |" space(0)
    "   kods  " space(0)
    "|   ( uz pie-       " space(0)
    "|       maz–k       " space(0)
    "|     no 3 mёn.     " space(0)
    "|     no 6 mёn.     " space(0)
    "|     no 1 gada     " space(0)
    "|    no 5 gadiem    " space(0)
    "|       03+04+      |" space(0)
    skip
    "|                                                  |" space(0)
    "         " space(0)
    "|    prasijumu      " space(0)
    "|       3 mёn.      " space(0)
    "|       lЁdz        " space(0)
    "|       lЁdz        " space(0)
    "|       lЁdz        " space(0)
    "|     un ilg–k      " space(0)
    "|       05+06)      |" space(0)
    skip


    "|                                                  |" space(0)
    "         " space(0)
    "|                   " space(0)
    "|                   " space(0)
    "|       6 mёn.      " space(0)
    "|      1 gadam      " space(0)
    "|      5 gadiem     " space(0)
    "|                   " space(0)
    "|                   |" space(0)
    skip
    fill("-",202) format "x(202)"
    skip

    "|                                                  |" space(0)
    "         " space(0)
    "|         01        " space(0)
    "|         02        " space(0)
    "|         03        " space(0)
    "|         04        " space(0)
    "|         05        " space(0)
    "|         06        " space(0)
    "|         07        |" space(0)
    skip
    fill("-",202) format "x(202)"
    skip
    with frame a11head width 204.
