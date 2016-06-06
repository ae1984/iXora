/* check_list.p
 * MODULE
        Операционист
 * DESCRIPTION
        check-list при открытии счета
 * RUN

 * CALLER
        cif-new2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        06/12/04 dpuchkov
 * CHANGES
        24.12.2012 Lyubov - ТЗ 1598 для юр.лиц. удалила строки дир. деп-та и юр.деп-т
		02.01.2013 id00477 - удалил строку "Копию документа, выданнного органом налоговой службы, подтверждающего факт постановки клиента на налоговый учет"
*/


def shared var s-cif like cif.cif.

{mainhead.i}
  def var file1 as char format "x(20)".
  file1 = "file1.html".
  find last cif where cif.cif = s-cif no-lock no-error.

  output to value(file1).
  {html-title.i}

find first ofc where ofc.ofc = g-ofc no-lock no-error.

    put unformatted
           "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
           "<TR align=""right"" style=""font:bold;font-size:10;background:white"">" skip
           "<TD width=""30%"" align=""left""> КЛИЕНТ </TD>" skip
           "<TD width=""70%"" align=""left"">" cif.name "</TD>" skip
           "</TR>" skip.
    put unformatted
           "<TR align=""right"" style=""font:bold;font-size:10;background:white"">" skip
           " <TD width=""30%"" align=""left""> ДАТА ФОРМИРОВАНИЯ </TD>" skip
           " <TD width=""70%"" align=""left"">" g-today "</TD>" skip
           " </TR>" skip.
    put unformatted "</TABLE>" skip.


    put unformatted
           "<br>   </br>" skip.

    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small""></P>" skip

        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""left"" style=""font:bold;background:gainsboro"">" skip
        "<TD>N</TD>" skip
        "<TD>ЮРИДИЧЕСКИЕ ЛИЦА РЕЗИДЕНТЫ</TD>" skip
        "<TD>Дата документа</TD>" skip
        "<TD>Дата документа</TD>" skip
        "</TR>" skip.
    put unformatted
        "<TR align=""left"" style=""background:white "">" skip
        "<TD>1</TD>" skip
        "<TD>Договор банковского счета</TD>" skip
        "<TD>" g-today "</TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
    put unformatted
        "<TR align=""left"" style=""background:white "">" skip
        "<TD>2</TD>" skip
        "<TD>Документ с образцами подписей и оттиска печати;</TD>" skip
        "<TD> </TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
    put unformatted
        "<TR align=""left"" style=""background:white "">" skip
        "<TD>3</TD>" skip
        "<TD>Копию статистической карточки</TD>" skip
        "<TD> </TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
    put unformatted
        "<TR align=""left"" style=""background:white "">" skip
        "<TD>4</TD>" skip
        "<TD>Копию документа установленной формы, выданного уполномоченным органом, подтверждающего факт прохождения  государственной регистрации(перерегистрации);" skip
        "<TD>" cif.expdt "</TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
    put unformatted
        "<TR align=""left"" style=""background:white "">" skip
        "<TD>5</TD>" skip
        "<TD>Для филиалов и представительств - копия доверенности, выданная юридическим лицом-резидентом Республики Казахстан руководителю филиала или представительства; </TD>" skip
        "<TD> </TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
    put unformatted
        "<TR align=""left"" style=""background:white "">" skip
        "<TD>6</TD>" skip
        "<TD>Нотариально удостоверенную копию устава (для обособленных подразделений - Положения) либо документа, подтверждающего факт деятельности клиента на основании типового устава; </TD>" skip
        "<TD>" cif.expdt "</TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
    put unformatted
        "<TR align=""left"" style=""background:white "">" skip
        "<TD>7</TD>" skip
        "<TD>Для государственных учереждений, финанасируемых из государственного бюджета - разрешение Министерства финансов Республики Казахстан.</TD>" skip
        "<TD> </TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
    put unformatted
        "<TR align=""left"" style=""background:white "">" skip
        "<TD>8</TD>" skip
        "<TD>Извещение об открытии счетов в налоговый комитет </TD>" skip
        "<TD>" g-today "</TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
    put unformatted
        "<TR align=""left"" style=""background:white "">" skip
        "<TD>9</TD>" skip
        "<TD>  </TD>" skip
        "<TD>  </TD>" skip
        "<TD> </TD>"  skip
        "</TR>"       skip.
    put unformatted       "</TABLE>" skip.

    put unformatted
           "<br>   </br>" skip
           "<br>   </br>" skip
           "<br>   </br>" skip.

    if cif.type = 'B' then do:
        put unformatted
               "<TABLE width=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
               "<TR align=""right"" style=""font:bold;font-size:11;background:white"">" skip
               " <TD width=""30%"" align=""left""> ИСПОЛНИТЕЛЬ </TD>" skip
               " <TD width=""25%"" align=""left"">" ofc.name "</TD>" skip
               " <TD width=""25%"" align=""left""> ДАТА  </TD>" skip
               " <TD width=""20%"" align=""left"">" g-today "</TD>" skip
               " </TR>" skip.
    end.
    else do:
        put unformatted
               "<TABLE width=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
               "<TR align=""right"" style=""font:bold;font-size:11;background:white"">" skip
               " <TD width=""30%"" align=""left""> ИСПОЛНИТЕЛЬ </TD>" skip
               " <TD width=""25%"" align=""left"">       </TD>" skip
               " <TD width=""25%"" align=""left""> ДАТА  </TD>" skip
               " <TD width=""20%"" align=""left"">"  "</TD>" skip
               " </TR>" skip.
        put unformatted
               "<br>   </br>" skip.
        put unformatted
               "<TR align=""right"" style=""font:bold;font-size:11;background:white"">" skip
               " <TD width=""30%"" align=""left""> ДИРЕКТОР ДЕПАРТАМЕНТА </TD>" skip
               " <TD width=""25%"" align=""left""> Бояркина И.Я. </TD>" skip
               " <TD width=""25%"" align=""left""> ДАТА  </TD>" skip
               " <TD width=""20%"" align=""left"">" g-today "</TD>" skip
               " </TR>" skip.
        put unformatted
               "<br>   </br>" skip.
        put unformatted
               "<TR align=""right"" style=""font:bold;font-size:11;background:white"">" skip
               " <TD width=""30%"" align=""left""> ЮРИДИЧЕСКИЙ ДЕПАРТАМЕНТ </TD>" skip
               " <TD width=""25%"" align=""left"">       </TD>" skip
               " <TD width=""25%"" align=""left""> ДАТА  </TD>" skip
               " <TD width=""20%"" align=""left"">       </TD>" skip
               " </TR>" skip.
    end.
    put unformatted "</TABLE>" skip.
  {html-end.i " "}
   output close.
   hide frame ww.

/* unix silent cptwin value(file1) iexplore. */
   unix silent value("cptwin file1.html winword").









