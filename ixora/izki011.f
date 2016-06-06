/* izki011.f
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
    "|" space(0)
    izki.name format "x(50)" space(0)
    "|" space(0)
    izki.kods format "x(9)"  space(0)
    "|" space(0)
    izki.summa[1] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[2] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[3] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[4] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[5] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[6] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[7] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    with frame a11 width 205 no-box no-label no-underline.

form
    header
    "turpin–jums ..." at 93
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

/*    12345678901234567890123456789012345678901234567890    */
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

    with frame a11h width 205 no-box no-label page-top no-underline.

form
    header
    fill("-",202) format "x(202)"
    skip
    "turpin–jums n–koma lap– ..." at 87
    with frame a11t width 205 no-box no-label page-bottom no-underline.


form
    "|" space(0)
    "Kop– visas kredЁtiest–des" space(0)
    "|" at 62 space(0)
    izki.summa[1] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[2] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[3] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[4] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[5] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[6] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" space(0)
    izki.summa[7] format ">>,>>>,>>>,>>>,>>9-" space(0)
    "|" skip(0)
    header
	fill("-",202) format "x(202)"
    with frame a11a width 205 no-box no-label no-underline.


form
    header
    fill("-",202) format "x(202)"

/*    12345678901234567890123456789012345678901234567890    */
    "| AtbilstoЅie pozЁciju kodi un aiµu numuri          " space(0)
    "         " space(0)
    "|pielikuma A-1      " space(0)
    "|pielikuma A-1      " space(0)
    "|pielikuma A-1      " space(0)
    "|pielikuma A-1      " space(0)
    "|pielikuma A-1      " space(0)
    "|pielikuma A-1      " space(0)
    "|pielikuma A-1      |" space(0)
    skip

    "|mёneЅa bilances p–rskat– un pielikumos             " space(0)
    "         " space(0)
    "|poz.03201. 01.aile " space(0)
    "|poz.03201. 02.aile " space(0)
    "|poz.03201. 03.aile " space(0)
    "|poz.03201. 04.aile " space(0)
    "|poz.03201. 05.aile " space(0)
    "|poz.03201. 06.aile " space(0)
    "|poz.03201. 07.aile*|" space(0)
    skip
    fill("-",202) format "x(202)"
    skip

    "* 07.ailes kopsummai j–sakrЁt arЁ ar bilances p–rskata aktЁva"
    "0321.,0322.,0323.,0324. pozЁciju" v-col0 format "9" space(0)
    ".ailes kopsummu."

    with frame a11e width 210 no-box no-label no-underline.
