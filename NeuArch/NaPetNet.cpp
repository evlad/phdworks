/* NaPetNet.cpp */
static char rcsid[] = "$Id: NaPetNet.cpp,v 1.4 2001-05-15 06:02:22 vlad Exp $";
//---------------------------------------------------------------------------

#include <stdarg.h>

#include "NaExcept.h"
#include "NaLogFil.h"
#include "NaStrOps.h"
#include "NaPetNet.h"
#include "NaPetCn.h"


//---------------------------------------------------------------------------
// Autoname facility counter
int     NaPetriNet::iNetNumber = 0;


#if defined(unix)
//---------------------------------------------------------------------------
// Flag of user break signal
bool		NaPetriNet::bUserBreak = false;


//---------------------------------------------------------------------------
// Signal handler
void
NaPetriNet::user_break (int signum)
{
    bUserBreak = true;

    // Repeat register the signal handler oncve again
    struct sigaction	sa, sa_old;
    sa.sa_handler = user_break;
    sa.sa_flags = SA_ONESHOT;
    sigaction(SIGINT, &sa, &sa_old);
    sigaction(SIGTERM, &sa, &sa_old);
    sigaction(SIGQUIT, &sa, &sa_old);
}
#endif /* unix */


//---------------------------------------------------------------------------
// Create empty network
NaPetriNet::NaPetriNet (const char* szNetName)
{
    // Setup default timer
    pTimer = &TheTimer;
    bTimeChart = false;
    dfTimeChart = NULL;
    pTimingNode = NULL;

    if(NULL == szNetName)
        szName = autoname("pnet", iNetNumber);
    else
        szName = newstr(szNetName);
}


//---------------------------------------------------------------------------
// Destroy the network
NaPetriNet::~NaPetriNet ()
{
    delete dfTimeChart;
    delete[] szName;
}


//---------------------------------------------------------------------------
// Get the network name
const char*
NaPetriNet::name ()
{
    return szName;
}


//---------------------------------------------------------------------------
// Get the timer
NaTimer&
NaPetriNet::timer ()
{
    return *pTimer;
}


//---------------------------------------------------------------------------
// Query for given node: true - exist; false - doesn't
bool
NaPetriNet::ask_for_node (NaPetriNode* pNode, int *pIndex)
{
    int i;
    for(i = 0; i < pnaNet.count(); ++i){
        if(pNode == pnaNet[i]){
            if(NULL != pIndex){
                *pIndex = i;
            }
            return true;
        }
    }
    return false;
}


//---------------------------------------------------------------------------

/////////////////////
// Runtime control //
/////////////////////

//---------------------------------------------------------------------------
// Prepare the network before start and return true if it's ready and false
// if verification is failed.
bool
NaPetriNet::prepare (bool bDoPrintouts)
{
    int     iNode;
    bool    bFailed;

    // Do preparation phases

    if(bDoPrintouts){
        NaPrintLog("# net '%s', phase #0: preparation.\n", name());
    }

    iPrevIndex = -1;
    dfTimeChart = NULL;
    if(bTimeChart){
        char    fname[80];
        sprintf(fname, "%s.grf", name());

        if(bDoPrintouts){
            NaPrintLog("Time chart is on -> %s.\n", fname);
        }

        dfTimeChart = OpenOutputDataFile(fname);
        if(NULL == dfTimeChart){
            NaPrintLog("time chart file opening failed.\n");
        }else{
            char    title[80];
            sprintf(title, "Time chart for petri network '%s'", name());
            dfTimeChart->SetVarName(0, "*TIME*");
        }
    }

    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        // Setup pointer to the network
        pnaNet[iNode]->pNet = this;

        // Disallow changes of node parameters
        pnaNet[iNode]->bTunable = false;

        // Setup 0 past calls for node activity
        pnaNet[iNode]->nCalls = 0;

        // Setup 0 past activations of node
        pnaNet[iNode]->nActivations = 0;

        // Need to initialize connectors
        int iCn;
        for(iCn = 0; iCn < pnaNet[iNode]->connectors(); ++iCn){
            if(bDoPrintouts){
                NaPrintLog("node '%s', connector '%s'\n",
                           pnaNet[iNode]->name(),
                           pnaNet[iNode]->connector(iCn)->name());
            }
            pnaNet[iNode]->connector(iCn)->init();
        }

        // Add node to time chart
        if(NULL != dfTimeChart){
            dfTimeChart->SetVarName(1 + iNode, pnaNet[iNode]->name());
        }
    }

    if(bDoPrintouts){
        NaPrintLog("# net '%s', phase #1: open input data.\n", name());
    }

    // 1. Open input data (pure output nodes) and get their dimensions
    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        try{
            if(bDoPrintouts){
                NaPrintLog("node '%s'\n", pnaNet[iNode]->name());
            }
            pnaNet[iNode]->open_input_data();
        }catch(NaException exCode){
            NaPrintLog("Open input data phase (#1): node '%s' fault.\n"
                       "Caused by exception: %s\n",
                       pnaNet[iNode]->name(), NaExceptionMsg(exCode));
        }
    }

    if(bDoPrintouts){
        NaPrintLog("# net '%s', phase #2: link connectors inside the node.\n",
                   name());
    }

    // 2. Link connectors inside the node
    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        try{
            if(bDoPrintouts){
                NaPrintLog("node '%s'\n", pnaNet[iNode]->name());
            }
            pnaNet[iNode]->relate_connectors();
        }catch(NaException exCode){
            NaPrintLog("Link connectors phase (#2): node '%s' fault.\n"
                       "Caused by exception: %s\n",
                       pnaNet[iNode]->name(), NaExceptionMsg(exCode));
        }
    }

    if(bDoPrintouts){
        NaPrintLog("# net '%s', phase #3: open output data.\n", name());
    }

    // 3. Open output data (pure input nodes) and set their dimensions
    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        try{
            if(bDoPrintouts){
                NaPrintLog("node '%s'\n", pnaNet[iNode]->name());
            }
            pnaNet[iNode]->open_output_data();
        }catch(NaException exCode){
            NaPrintLog("Open output data phase (#3): node '%s' fault.\n"
                       "Caused by exception: %s\n",
                       pnaNet[iNode]->name(), NaExceptionMsg(exCode));
        }
    }

    if(bDoPrintouts){
        NaPrintLog("# net '%s', phase #4: allocate resources.\n", name());
    }

    // 4. Allocate resources for internal usage
    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        try{
            if(bDoPrintouts){
                NaPrintLog("node '%s'\n", pnaNet[iNode]->name());
            }
            pnaNet[iNode]->allocate_resources();
        }catch(NaException exCode){
            NaPrintLog("Allocate resources phase (#4): node '%s' fault.\n"
                       "Caused by exception: %s\n",
                       pnaNet[iNode]->name(), NaExceptionMsg(exCode));
        }
    }

    if(bDoPrintouts){
        NaPrintLog("# net '%s', phase #5: verification.\n", name());
    }

    // 5. Verification to be sure all is OK (true)
    bFailed = false;
    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        try{
            if(bDoPrintouts){
                NaPrintLog("node '%s'\n", pnaNet[iNode]->name());
            }
            if(!pnaNet[iNode]->verify()){
                bFailed = bFailed || true;
                NaPrintLog("Node '%s' verification failed!\n",
                           pnaNet[iNode]->name());
            }
        }catch(NaException exCode){
            bFailed = bFailed || true;
            NaPrintLog("Verification phase (#5): node '%s' fault.\n"
                       "Caused by exception: %s\n",
                       pnaNet[iNode]->name(), NaExceptionMsg(exCode));
        }
    }

    if(bDoPrintouts){
        NaPrintLog("Petri net '%s' map:\n", name());
        for(iNode = 0; iNode < pnaNet.count(); ++iNode){
            int         iCn;
            NaPetriNode &node = *pnaNet[iNode];

            NaPrintLog("* node '%s', connectors:\n", node.name());
            for(iCn = 0; iCn < node.connectors(); ++iCn){
                NaPrintLog("  #%d ", iCn + 1);
                node.connector(iCn)->describe();
            }
        }
    }

    if(bFailed){
        return false;
    }

    if(bDoPrintouts){
        NaPrintLog("# net '%s', phase #6: initialization.\n", name());
    }

    // 6. Initialize node activity and setup starter flag if needed
    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        try{
            bool    bStarter = false;

            if(bDoPrintouts){
                NaPrintLog("node '%s'\n", pnaNet[iNode]->name());
            }
            pnaNet[iNode]->initialize(bStarter);

            if(bStarter){
                if(bDoPrintouts){
                    NaPrintLog("node '%s' is starter.\n",
                               pnaNet[iNode]->name());
                }

                // Each starter node must commit output data at initialize
                // phase of execution due to semantics may be complicated
                // enough and be obscured from net.
                //OLD If the node is starter then it produced output data
                //OLD on the initialize phase already
                //OLD pnaNet[iNode]->commit_data(pckOutput);
            }
        }catch(NaException exCode){
            NaPrintLog("Initialization phase (#6): node '%s' fault.\n"
                       "Caused by exception: %s\n",
                       pnaNet[iNode]->name(), NaExceptionMsg(exCode));
        }
    }

#if defined(unix)
    // Prepare value of handling user break
    bUserBreak = false;

    // Register the signal handler
    struct sigaction	sa, sa_old;
    sa.sa_handler = user_break;
    sa.sa_flags = SA_ONESHOT;
    sigaction(SIGINT, &sa, &sa_old);
    sigaction(SIGTERM, &sa, &sa_old);
    sigaction(SIGQUIT, &sa, &sa_old);
#endif /* unix */

    return true;
}


//---------------------------------------------------------------------------
// Run the network for one step and return state of the network
NaPNEvent
NaPetriNet::step_alive (bool bDoPrintouts)
{
    int     iNode;
    int     nHalted = 0;
    int     iActive = 0;

    if(bDoPrintouts){
        NaPrintLog("# net '%s', step phases 7, 8, 9.\n", name());
    }

    // Add point to timechart
    if(NULL != dfTimeChart){
        dfTimeChart->AppendRecord();

        // Time track
        if(iPrevIndex == timer().CurrentIndex()){
            dfTimeChart->SetValue(0.0/* old */, 0/* time */);
        }else{
            dfTimeChart->SetValue(0.8/* new */, 0/* time */);
        }
    }

    if(bDoPrintouts)
      NaPrintLog("----------------------------------------\n");

    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        bool    bActivate = false;

        try{
            // 7. Do one step of node activity and return true if succeeded
            if(bDoPrintouts || pnaNet[iNode]->is_verbose()){
                NaPrintLog("node '%s' try to activate.\n",
                           pnaNet[iNode]->name());
            }
            bActivate = pnaNet[iNode]->activate();

            // Count calls
            ++pnaNet[iNode]->nCalls;

            if(bDoPrintouts || pnaNet[iNode]->is_verbose()){
                NaPrintLog("node '%s' is %sactivated.\n",
                           pnaNet[iNode]->name(), bActivate?"" :"not ");
            }

	    // Node is timing one
	    if(bActivate && pnaNet[iNode] == pTimingNode)
	      timer().GoNextTime();

        }catch(NaException exCode){
            NaPrintLog("Step of node activity phase (#7): node '%s' fault.\n"
                       "Caused by exception: %s\n",
                       pnaNet[iNode]->name(), NaExceptionMsg(exCode));
            bActivate = false;
        }

        if(bActivate){
            ++iActive;

            try{
                // 8. True action of the node (if activate returned true)
                if(bDoPrintouts || pnaNet[iNode]->is_verbose()){
                    NaPrintLog("node '%s' action.\n", pnaNet[iNode]->name());
                }
                pnaNet[iNode]->action();

                // Count activations
                ++pnaNet[iNode]->nActivations;

            }catch(NaException exCode){
                NaPrintLog("True action phase (#8): node '%s' fault.\n"
                           "Caused by exception: %s\n",
                           pnaNet[iNode]->name(), NaExceptionMsg(exCode));
            }

            try{
                // 9. Finish data processing by the node (if activate
                //    returned true)
                if(bDoPrintouts || pnaNet[iNode]->is_verbose()){
                    NaPrintLog("node '%s' post action.\n",
                               pnaNet[iNode]->name());
                }
                pnaNet[iNode]->post_action();
            }catch(NaException exCode){
                NaPrintLog("Postaction phase (#9): node '%s' fault.\n"
                           "Caused by exception: %s\n",
                           pnaNet[iNode]->name(), NaExceptionMsg(exCode));
            }

            // Check for internal halt
            if(pnaNet[iNode]->bHalt){
                ++nHalted;
            }
        }

        try{
            if(bDoPrintouts || pnaNet[iNode]->is_verbose()){
                pnaNet[iNode]->describe();
            }
        }catch(NaException exCode){
            // Skip...
        }

        // Add node point to time chart
        if(NULL != dfTimeChart){
            if(bActivate){
                dfTimeChart->SetValue(-(1 + iNode) + 0.8/* active */, 1+iNode);
            }else{
                dfTimeChart->SetValue(-(1 + iNode)/* passive */, 1+iNode);
            }
        }
    }

    //// Add point to timechart
    //if(NULL != dfTimeChart){
    //    dfTimeChart->AppendRecord();
    //
    //    // Time track
    //    dfTimeChart->SetValue(0.0/* old */, 0/* time */);
    //}

    if(0 == iActive){
        return pneDead;
    }else if(0 != nHalted){
        return pneHalted;
    }

#if defined(unix)
    if(bUserBreak)
      return pneTerminate;
#endif /* unix */

    return pneAlive;
}


//---------------------------------------------------------------------------
// Send gentle termination signal to the network and be sure all
// data are closed and resources are released after the call
void
NaPetriNet::terminate (bool bDoPrintouts)
{
    int     iNode;

    if(bDoPrintouts){
        NaPrintLog("# net '%s', phase #10: deallocation and closing data.\n",
                   name());
    }

    // 10. Deallocate resources and close external data
    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        try{
            if(bDoPrintouts){
                NaPrintLog("node '%s'\n", pnaNet[iNode]->name());
            }
            pnaNet[iNode]->release_and_close();
        }catch(NaException exCode){
            NaPrintLog("Deallocate resources phase (#10): node '%s' fault.\n"
                       "Caused by exception: %s\n",
                       pnaNet[iNode]->name(), NaExceptionMsg(exCode));
        }
    }

    // Allow changes of node parameters
    for(iNode = 0; iNode < pnaNet.count(); ++iNode){
        pnaNet[iNode]->bTunable = true;
    }

    if(NULL != dfTimeChart){
        delete dfTimeChart;
        dfTimeChart = NULL;
    }

#if defined(unix)
    // Reset the signal handler
    struct sigaction	sa, sa_old;
    sa.sa_handler = SIG_DFL;
    sigaction(SIGINT, &sa, &sa_old);
    sigaction(SIGTERM, &sa, &sa_old);
    sigaction(SIGQUIT, &sa, &sa_old);
#endif /* unix */
}


//---------------------------------------------------------------------------
// Special facility for time-chart creation
void
NaPetriNet::time_chart (bool bDoTimeChart)
{
    bTimeChart = bDoTimeChart;
}


//---------------------------------------------------------------------------

///////////////////////
// Build the network //
///////////////////////

//---------------------------------------------------------------------------
// All these methods are applied before prepare()
// and after terminate()!

//---------------------------------------------------------------------------
// Link Src->Dst connection chain
void
NaPetriNet::link (NaPetriConnector* pcSrc, NaPetriConnector* pcDst)
{
    if(NULL == pcSrc || NULL == pcDst)
        throw(na_null_pointer);

#if 1
    // Why not?
    if(pcSrc->host() == pcDst->host())
        // Can't link together two connectors of the same host node
        throw(na_not_compatible);
#endif

    add(pcSrc->host());
    add(pcDst->host());

    if(!pcSrc->link(pcDst) || !pcDst->link(pcSrc))
        // Can't link together two connectors of different type
        throw(na_not_compatible);

    NaPrintLog("Link %s.%s & %s.%s\n",
               pcSrc->host()->name(), pcSrc->name(),
               pcDst->host()->name(), pcDst->name());
}


//---------------------------------------------------------------------------
// Link mainstream chain of nodes
void
NaPetriNet::link_nodes (NaPetriNode* pNode0, ...)
{
    NaPetriNode *pNodeCur, *pNodePrev;
    va_list     val;
    const char  *szExMsg =
        "Broken mainstream chain from '%s' to '%s' node.\n"
        "Caused by exception: %s\n";

    pNodePrev = NULL;
    pNodeCur = pNode0;

    for(va_start(val, pNode0);
        NULL != pNodeCur;
        pNodeCur = va_arg(val, NaPetriNode*)){

        // Link prev with current
        if(NULL != pNodePrev){
            try{
                if(NULL == pNodePrev->main_output_cn()){
                    NaPrintLog("Undefined mainstream output connector"
                               " for node '%s'", pNodePrev->name());
                }else if(NULL == pNodeCur->main_input_cn()){
                    NaPrintLog("Undefined mainstream input connector"
                               " for node '%s'", pNodeCur->name());
                }else{
                    link(pNodePrev->main_output_cn(),
                         pNodeCur->main_input_cn());
                }
            }catch(NaException exCode){
                NaPrintLog(szExMsg, pNodePrev->name(), pNodeCur->name(),
                           NaExceptionMsg(exCode));
            }
        }
        pNodePrev = pNodeCur;
    }

    va_end(val);
}


//---------------------------------------------------------------------------
// Add node to the network without connections
void
NaPetriNet::add (NaPetriNode* pNode)
{
    if(ask_for_node(pNode)){
        // Don't add the same node twice
        return;
    }
    pnaNet.addh(pNode);
}


//---------------------------------------------------------------------------
// Unlink Src->Dst connection chain
void
NaPetriNet::unlink (NaPetriConnector* pcSrc, NaPetriConnector* pcDst)
{
    if(NULL == pcSrc || NULL == pcDst)
        throw(na_null_pointer);

    pcSrc->unlink(pcDst);
    pcDst->unlink(pcSrc);

    NaPrintLog("Unlink %s.%s & %s.%s\n",
               pcSrc->host()->name(), pcSrc->name(),
               pcDst->host()->name(), pcDst->name());
}


//---------------------------------------------------------------------------
// Setup timer
void
NaPetriNet::set_timer (NaTimer* pTimer_)
{
    if(NULL == pTimer_)
        // Restore default timer
        pTimer = &TheTimer;
    else
        pTimer = pTimer_;
}


//---------------------------------------------------------------------------
// Setup timing node; timer steps when node is activated
void
NaPetriNet::set_timing_node (NaPetriNode* pTimingNode_)
{
  pTimingNode = pTimingNode_;

  if(NULL == pTimingNode)
    NaPrintLog("Timing node is off\n");
  else
    NaPrintLog("Timing node '%s' (%p)\n", pTimingNode->name(), pTimingNode);
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
