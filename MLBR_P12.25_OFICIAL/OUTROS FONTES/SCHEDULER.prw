/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SCHEDULER �Autor  � Equipe de Projetos � Data �  13/02/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa que ira chamar o Scheduler                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SCHEDULER()
************************
LOCAL aParams := {}
Public aMandouMail := {}
Aadd(aParams,"01") //Empresa
Aadd(aParams,"12") //Filial
WFSCHEDULER(aParams)

Return(.T.)