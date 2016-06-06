/* astp.f
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
            24/05/2013 Luiza - ТЗ 1842 закрепление ОС за сотрудником

*/

form
 "Nr КАРТОЧКИ  :" ast.ast format "x(8)" "    ИНВЕНТ.Nr." ast.addr[2] format "x(20)"
                                      " Откр."  ast.whn /* ast.who */ skip
 "НАЗВАНИЕ     :" ast.name      v-fil at 47 format "x(4)" " " v-filn format "x(24)" skip
 "СЧЕТ         :" ast.gl format "zzzzz9" v-gl1d format "x(20)" skip
 "             :" v-gl3 format "zzzzz9"  v-gl3d format "x(20)"
        "ГРУППА" ast.fag format "xxx" v-fagn format "x(24)" skip
 "ДАТА РЕГИСТР.:" ast.rdt "--------> с ПЕРВ.СТОИМ. :" at 26
                                            v-nach format "zzzz,zzz,zz9.99-"
                                       ast.meth format "zzz9-" "шт. " skip
 "КОЛ-ВО      :" ast.qty format "zzz9-"
            "    с ИЗНОСОМ  :" at 35 ast.salv format "zzzz,zzz,zz9.99-"skip
 "ОСТАТ.СТОИМ.:" v-atl  format "zzzzzz,zzz,zz9.99-"
            "СРОК AMOPT.:" at 34 ast.noy format "zz9" "лет"
                        "МЕС.АМОРТ.:" ast.amt[1] format "zzzzzzz9.99-" skip
  "КОД :" at 34  ast.ser format "x(6)"
                                    "  ПОСЛЕД.РАСЧ.АМОРТ:"  ast.ldd skip
 "БАЛАНС.СТОИМ:" v-icost format "zzzzzz,zzz,zz9.99-"
                  ":" ast.dam[1] format "zzzzzz,zzz,zz9.99-" "DR"
                      ast.cam[1] format "zzzzzz,zzz,zz9.99-" "CR"  skip

 "НАКОПЛ.АМОРТ:" v-nol format "zzzzzz,zzz,zz9.99-"
                  ":"  ast.dam[3] format "zzzzzz,zzz,zz9.99-" "DR"
                       ast.cam[3] format "zzzzzz,zzz,zz9.99-" "CR" skip
"----------------- Данные для расчета налогового износа   --------------------" SKIP
 "   КАТЕГОРИЯ:" f-cont format "x(2)"  " ПОДКАТЕГОРИЯ:" f-ref format "x(2)"
 " Аммортизация (0-Нет, 1-Да) :" ast.ref format "x(2)" skip
/* "ОСТ.СТ. НАЛ. НА ДАТУ  :" ast.ddt[1]  ast.crline  format "zzzzzzzzz9.99-"
                         " изм.тек.г." ast.ydam[5] format "zzzzzzzzz9.99-"  skip */
  "ОСТАТ.СТОИМ. НАЛОГ. :" ast.ddt[4]  ast.amt[4]  format "zzzzzzzzz9.99-"
                         " изм. :" ast.ycam[5] format "zzzzzzzzz9.99-"  skip
"-----------------------------------------------------------------------------" SKIP
 "ОТВЕТСТВ.ЛИЦО:" ast.addr[1] format "x(5)" " " v-addrn format "x(25)"
                              "Коррект.:" at 58 ast.updt   skip
 "МЕСТО РАСПОЛ.:" ast.attn format "x(5)" " " v-attnn format "x(25)"
                                          ast.ofc at 67 skip
 "ПРИМЕЧАНИЕ   :"ast.rem skip
 "ЗАКРЕПЛЕН    :" ast.own format "x(7)" /* validate(can-find(first ofc where ofc.ofc = ast.own no-lock),"Не верный id!") */ "   " v-ofc help "Введите начальные буквы фамилии" format "x(25)"skip
 "ПАСПОРТ.ДАН. :"ast.mfc  skip

  with frame astp row 1 overlay centered no-labels no-hide
    title "  ПРОСМОТР И КОРРЕКТИРОВКА КАРТОЧКИ ОСНОВНОГО СРЕДСТВА".


/***************************************
form
 "Nr КАРТОЧКИ  :" ast.ast format "x(8)" "  ИНВЕНТ.Nr." at 42 ast.addr[2] format
 "НАЗВАНИЕ     :" ast.name                "Откр" at 50 ast.whn ast.who skip
 "СЧЕТ         :" ast.gl format "zzzzz9" gl.des format "x(20)"
        "ГРУППА" ast.fag format "xxx" v-fagn format "x(24)" skip(1)

 "ДАТА РЕГИСТР.:" ast.rdt "--------> с ПЕРВ.СТОИМ. :" at 26 v-nach ast.meth
                         format "zzz9-" "шт. " skip
 "ПЕРВ.СТОИМОСТЬ" ast.icost format "zzz,zzz,zz9.99-"
            "  с ИЗНОСОМ    :" at 35 ast.salv format "zzz,zzz,zz9.99-"skip
 "КОЛ-ВО       :" ast.qty format "zzz9-"
            "СРОК ИЗНОСА лет:" at 35 ast.noy format "zz9"
                  "КОД :" at 66  ast.ser format "x(5)"skip
 "ОСТАТ.СТОИМ. :" v-atl   "PЁD.NOLIET.APR.:" at 35 ast.ldd skip
 "ИЗНОС        :" v-nol
         "СУММА МЕС.ИЗН. :" at 35 ast.amt[1] format "zzz,zzz,zz9.99-" skip
 "ОБОРОТЫ      :"  ast.dam[1] format "zzz,zzz,zz9.99-"
 " Д " ast.cam[1] format "zzz,zzz,zz9.99-" "К "  skip
"----------------- Данные для расчета налогового износа   --------------------" SKIP
 "   КАТЕГОРИЯ:" f-cont format "x(2)"  " ПОДКАТЕГОРИЯ:" f-ref format "x(2)"
 " Аммортизация (0-Нет, 1-Да) :" ast.ref format "x(2)" skip
/* "КАТЕГОРИЯ    :" ast.cont format "x(2)"
        "СТАВКА ИЗНОСА   " to 40 ast.ref format "x(2)" " % x 2 "skip
 "ОСТАТ.СТОИМ.ДЛЯ НАЛОГА" ast.ddt[1]  ast.crline  format "zzzzzzz9.99-"
                         " изм.в тек.г. " ast.ydam[5] format "zzzzzzzz9.99-"  */skip
"-----------------------------------------------------------------------------" SKIP
 "ОТВЕТСТВ.ЛИЦО:" ast.addr[1] format "x(5)" " " v-addrn format "x(25)"
                              "PED.IZM.:" at 58 ast.updt   skip
 "МЕСТО РАСПОЛ.:" ast.attn format "x(5)" " " v-attnn format "x(25)"
                                          ast.ofc at 67 skip
 "ПРИМЕЧАНИЕ   :"ast.rem skip
 "ПАСПОРТ.ДАН. :"ast.mfc  skip

  with frame astp row 1 overlay centered no-labels no-hide
    title "  ПРОСМОТР И КОРРЕКТИРОВКА КАРТОЧКИ ОСНОВНОГО СРЕДСТВА".

*********************************************/

