//---------------------------------------------------------------------------
#include "NaStrOps.h"
#include "NaExcept.h"
#include "NaPetNod.h"
#include "NaPetCn.h"


//---------------------------------------------------------------------------
// Autoname facility counter
int     NaPetriConnector::iCnNumber = 0;


//---------------------------------------------------------------------------
// Link to the host node
NaPetriConnector::NaPetriConnector (NaPetriNode* pHost, const char* szCnName)
{
    if(NULL == pHost)
        throw(na_null_pointer);

    pNode = pHost;

    if(NULL == szCnName)
        szName = autoname("conn", iCnNumber);
    else
        szName = newstr(szCnName);

    host()->add_cn(this);
}


//---------------------------------------------------------------------------
// Destroy the connector
NaPetriConnector::~NaPetriConnector ()
{
    host()->del_cn(this);

    delete[] szName;
}


//---------------------------------------------------------------------------
// Return pointer to host node
NaPetriNode*
NaPetriConnector::host () const
{
    return pNode;
}


//---------------------------------------------------------------------------
// Return name of the connector
const char*
NaPetriConnector::name () const
{
    return szName;
}


//---------------------------------------------------------------------------
// Return number of links of this connector
int
NaPetriConnector::links () const
{
    return pcaLinked.count();
}


//---------------------------------------------------------------------------
// Unlink the connector from this one and return true on success
bool
NaPetriConnector::unlink (NaPetriConnector* pLinked)
{
    int i;
    for(i = 0; i < pcaLinked.count(); ++i){
        if(pLinked == pcaLinked[i]){
            pcaLinked.remove(i);
            return true;
        }
    }
    return false;
}


//---------------------------------------------------------------------------
// Unlink all connectors from this one
void
NaPetriConnector::unlink ()
{
    pcaLinked.clean();
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
