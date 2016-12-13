#ifndef __TRADEX_H
#define __TRADEX_H

#include <Windows.h>

#ifdef __cplusplus
extern "C" {
#endif

//
// 交易API
//

void WINAPI OpenTdx();

void WINAPI CloseTdx();

int WINAPI Logon(
    const char* pszIP,
    short nPort,
    const char* pszVersion,
    short nYybID,
    const char* pszAccountNo,
    const char* pszTradeAccount,
    const char* pszJyPassword,
    const char* pszTxPassword,
    char* pszErrInfo);

void WINAPI Logoff(int nClientID);

void WINAPI QueryData(
    int nClientID,
    int nCategory,
    char* pszResult,
    char* pszErrInfo);

void WINAPI QueryHistoryData(
    int nClientID,
    int nCategory,
    const char* pszStartDate,
    const char* pszEndDate,
    char* pszResult,
    char* pszErrInfo);

void WINAPI QueryDatas(
    int nClientID,
    int nCategory[],
    int nCount,
    char* pszResult[],
    char* pszErrInfo[]);

void WINAPI SendOrder(
    int nClientID,
    int nCategory,
    int nPriceType,
    const char* pszGddm,
    const char* pszZqdm,
    float fPrice,
    int nQuantity,
    char* pszResult,
    char* pszErrInfo);

void WINAPI SendOrders(
    int nClientID,
    int nCategory[],
    int nPriceType[],
    const char* pszGddm[],
    const char* pszZqdm[],
    float fPrice[],
    int nQuantity[],
    int nCount,
    char* pszResult[],
    char* pszErrInfo[]);

void WINAPI CancelOrder(
    int nClientID,
    const char* pszExchangeID,
    const char* pszhth,
    char* pszResult,
    char* pszErrInfo);

void WINAPI CancelOrders(
    int nClientID,
    const char* pszExchangeID[],
    const char* pszhth[],
    int nCount,
    char* pszResult[],
    char* pszErrInfo[]);

void WINAPI GetQuote(
    int nClientID,
    const char* pszZqdm,
    char* pszResult,
    char* pszErrInfo);

void WINAPI GetQuotes(
    int nClientID,
    const char* pszZqdm[],
    int nCount,
    char* pszResult[],
    char* pszErrInfo[]);

void WINAPI Repay(
    int nClientID,
    const char* pszAmount,
    char* pszResult,
    char* pszErrInfo);


//
// 行情API
//

bool WINAPI TdxHq_Connect(
    const char *pszIP,
    short nPort,
    char *pszResult,
    char *pszErrInfo);

void WINAPI TdxHq_Disconnect();

bool WINAPI TdxHq_GetSecurityCount(
    char nMarket,
    short *nCount,
    char *pszErrInfo);

bool WINAPI TdxHq_GetSecurityList(
    char nMarket,
    short nStart,
    short *nCount,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetSecurityBars(
    char nCategory,
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *nCount,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetIndexBars(
    char nCategory,
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *nCount,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetMinuteTimeData(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetHistoryMinuteTimeData(
    char nMarket,
    const char *pszZqdm,
    int nDate,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetTransactionData(
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *nCount,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetHistoryTransactionData(
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *nCount,
    int nDate,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetSecurityQuotes(
    char nMarket[],
    const char *pszZqdm[],
    short *nCount,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetCompanyInfoCategory(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetCompanyInfoContent(
    char nMarket,
    const char *pszZqdm,
    const char *pszFileName,
    int nStart,
    int nLength,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetXDXRInfo(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

bool WINAPI TdxHq_GetFinanceInfo(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

#ifdef __cplusplus
}
#endif

#endif
