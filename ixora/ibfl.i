/* ibfl.i
 * MODULE
        ИБФЛ
 * DESCRIPTION
        Дополнительные функции для работы ИБФЛ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        07.06.2013 k.gitalov
 * BASES
        BANK COMM TXB
 * CHANGES
*/

/*********************************************************************************************/
function GetCardType returns character  (input parm1 as char).
    case parm1:
        when "E" then 
            do:
                return "VISA Electron".
            end.
        when "C" then 
            do:
                return "VISA Classic".
            end.
        when "G" then 
            do:
                return "VISA Gold".
            end.
        when "I" then 
            do:
                return "VISA Infinite".
            end.
        when "B" then 
            do:
                return "VISA Business".
            end.
        otherwise 
        do:
            return "UNKNOWN".
        end.
    end case.
end function.
/*********************************************************************************************/
function info_name_replacer returns character (input info_name as character).
    info_name = replace (info_name, "&", "&amp;").
    info_name = replace (info_name, ">", "&gt;").
    info_name = replace (info_name, "<", "&lt;").
    info_name = replace (info_name, """", "&quot;").
    info_name = replace (info_name, "'", "&apos;").
    return(info_name).
end function.
/*********************************************************************************************/
FUNCTION GetNormTel RETURNS CHAR (INPUT TEL AS CHAR):
  DEFINE VARIABLE BUFF AS CHARACTER FORMAT "x(40)".
    BUFF = REPLACE(TEL," ","").
    BUFF = REPLACE(BUFF,"-","").
    BUFF = REPLACE(BUFF,"+","").
    if length(BUFF) > 10 then BUFF = substring(BUFF,2,10).
  RETURN BUFF.
END FUNCTION.
/*********************************************************************************************/
function GetNormSumm returns char (input summ as deci ):
   def var ss1 as deci.
   def var ret as char.
   if summ >= 0 then 
   do:
    ss1 = summ.
    ret = string(ss1,"->>>>>>>>>>>>>>>>9.99").
   end. 
   else do:
    ss1 = - summ.
   ret = "-" + trim(string(ss1,"->>>>>>>>>>>>>>>>9.99")).
   end.
   return trim(replace(ret,".",",")). 
end function.
/*********************************************************************************************/
function GetSuppCaption returns char (input id as int ):
  define variable Rez as character no-undo.
       
  case id:
    when 1 or when 3 or when 7 or when 160 or when 503 or when 504 or when 211 or when 228 or when 298 or when 462 or when 463 or when 464 or when 502 or when 542 or when 551 or when 665 or when 682 or when 685 or when 686 or when 708 then do:
      Rez = "Введите номер телефона".
    end.
    when 507 or when 508 or when 585 or when 588 or when 619 or when 500 or when 514 or when 609 or when 610 or when 611 or when 612 or when 613 or when 614 or when 615 or when 616 or when 617 or when 684 or when 687 or when 688 or when 689 or when 690 or when 691 then do:
      Rez = "Введите номер счета".
    end.
    when 683 then do:
      Rez = "Введите номер платежа".
    end.
    when 208 then do:
      Rez = "Введите номер РНН и ИНН".
    end.
    when 57 or when 705 or when 706 or when 707 then do:
      Rez = "Введите номер ИИН/БИН".
    end.
    when 590 or when 654 or when 655 or when 656 or when 657 or when 659 or when 660 or when 661 or when 662 or when 663 or when 664 or when 680 then do:
      Rez = "Введите номер заказа".
    end.
    when 531 or when 4 or when 5 or when 58 or when 526 or when 535 or when 545 or when 546 or when 547 or when 548 or when 549 or when 575 or when 576 or when 577 or when 578 or when 579 or when 580 or when 581 or when 582 or when 583 or when 593 or when 594 or when 595 or when 596 then do:
      Rez = "Введите номер договора".
    end.
    when 501 or when 534 or when 543 or when 597 or when 603 then do:
      Rez = "Введите номер аккаунта".
    end.
    when 505 or when 506 or when 532 or when 539 or when 540 or when 675 or when 676 or when 677 or when 678 then do:
      Rez = "Введите номер".
    end.
    otherwise do:
      Rez =  "Введите номер лицевого счета".
    end.    
  end. /*case*/ 
  return Rez.   
end function.    
/*********************************************************************************************/
