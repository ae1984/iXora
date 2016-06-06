#!/bin/bash

# -------------------------------------------------------
# Processing merchant statements from HalykBank
# -------------------------------------------------------
# * CHANGES
#   30/04/2004 isaev - выпечатывается поле SLIP


###################################
# формирование выписки для печати
###################################
cat $1 | awk '
   
        BEGIN { print " "; print "                                 Merchant Statement By Period";
                CNT = 0;
                WASTOT = 0;
                RDTSTR = "";
                TYPESTR = "";
              }
   /\|REGD\|/ { RDTSTR = "                                   " $2 " - " $2; }
   /\|TYPE\|/ { TYPESTR = "                                             " $2; }                                    
   /\|CURR\|/ { print RDTSTR;
                print TYPESTR;
                print " ";
                print "--------------------------------------------------------------------------------------------------------------";
                printf ("   Валюта : %s", $2);
              }
   /\|CONT\|/ { printf ("                Контракт : %s\n", $2);
                print "--------------------------------------------------------------------------------------------------------------";
                print "Дата       Номер карты      Описание                   Сумма        Комиссия         К зачислению   Устройство";
                print " ";                                                                          
              }
   /\|TRDT\|/ { printf("%s ", $2);
              }
   /\|CARD\|/ { printf("%s ", $2);
              }            
   /\|NAME\|/ { NAME = substr($0,8,length($0));
                for (i=length(NAME); i<18; i++) {NAME = NAME " "}
                printf("%18s ", NAME);
              }
   /\|SUMA\|/ { printf("%15s ", $2);
              }
   /\|DISC\|/ { printf("%10s ", $2);
              }
   /\|SUMB\|/ { printf("%20s ", $2);
              }
   /\|DEVC\|/ { printf("%15s \n", $2);
              }
   /\|TOTA\|/ { WASTOT = 1;
                print "--------------------------------------------------------------------------------------------------------------";
                printf("                                       ВСЕГО : %15s ", $2);
              }
   /\|TOTD\|/ { printf("%10s ", $2);
              }
   /\|TOTB\|/ { printf("%20s \n\n\n\n", $2);
              }

          END {print "                                   End Of Merchant Statement"
              }
' | koi2win > $1.prt


###################################
# подготовка выписок для Прагмы
###################################
cat $1 | awk '
        BEGIN { CRC = "";
                CONT = "";
                CNT = 0;
              }                      # начальное значение
   /\|BANK\|/ { print $2 }           
              # дата выписки по НарБанку
   /\|REGD\|/ { if (CNT == 0) {print substr($0,8,length($0)); CNT = 1;} }
   /\|CURR\|/ { CRC = $2 }           # валюта (KZT, USD)
   /\|CONT\|/ { CONT = $2 }          # контракт
   /\|TRDT\|/ { print CRC;
                print CONT;
                print $2 }           # дата ориг. транзакции
   /\|CARD\|/ { print $2 }           # номер карточки
   /\|AUTH\|/ { print $2 }           # код авторизации
   /\|NAME\|/ { print substr($0,8,length($0)) }
   /\|SUMA\|/ { print $2 }           # ориг. сумма
   /\|DISC\|/ { print $2 }           # проценты НарБанка
   /\|SUMB\|/ { print $2 }           # итоговая сумма
   /\|DEVC\|/ { print $2 }           # устройство
   /\|SLIP\|/ { print $2 }           # slip код
' > $1.pragma

