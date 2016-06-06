/* platr.f
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

/***************************************************************************\
*****************************************************************************
**  Program: plat.f
**       By:
** Descript:
**
*****************************************************************************
\***************************************************************************/

FORM
  SPACE (18)
  "ПЛАТЕЖНОЕ ПОРУЧЕНИЕ  # "   pla.nmb  "  ДАТА:" pla.regdt  SKIP(1)
  "СУММА   " at 70 SKIP
  "Отправитель денег:"           "ИИК " at 47  "КОд"  at 58 skip
  pla.ma1  pla.rs1 at 47 pla.ve format 'x(2)' at 59 pla.summ  at 60 SKIP
  "РНН "  pla.ma2  format 'x(12)' skip(1)  
  "Банк-получатель:"    "БИК"  at 47 "Валюта"at 70  skip
  pla.ba1  pla.kb2 at 47  pla.code format 'x(5)' at 70 skip(1)
  "Бенефициар:"            "ИИК " at 47  "КБе"  at 58 skip
  pla.sa1   pla.rs2 at 47 pla.me  format 'x(2)' at 59  SKIP
  "РНН " pla.sa2 format 'x(12)'     SKIP(1)
  "Банк бенефициара:"              "БИК"  at 47 skip
  pla.ba2   pla.kb4  at 47 SKIP(1)
  "Дата получения товара (оказания услуг):"  SKIP     
  pla.ba3 format 'x(10)'                    skip              
  "Назначение платежа:"                      "КНП" at 60 SKIP
  pla.ap[1]  format 'x(39)' pla.rs3 format 'x(3)' at 60 SKIP
  pla.ap[2] format 'x(39)' "КБК" at 60 SKIP
  pla.ap[3]  format 'x(39)' pla.rs4 format 'x(6)' at 60 SKIP
  pla.ap[4] format 'x(39)' "Дата вал." at 60 SKIP
  pla.ap[5] format 'x(39)'  pla.ba4 format 'x(10)' at 60 SKIP
                        
  /*
  123456789012345678901234567890123456789012345678901234567890123456789012345
  */      

  WITH  /* overlay RAW 3 */ NO-LABEL NO-BOX FRAME platr no-hide.
