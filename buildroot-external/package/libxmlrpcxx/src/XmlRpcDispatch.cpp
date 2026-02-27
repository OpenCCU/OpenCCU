
/* changed by eQ-3 Entwicklung GmbH 2006 */


#include "XmlRpcDispatch.h"
#include "XmlRpcSource.h"
#include "XmlRpcUtil.h"

#include <math.h>
#include <sys/timeb.h>
#include <time.h>

#if defined(_WINDOWS)
# include <winsock2.h>

# define USE_FTIME
# if defined(_MSC_VER)
#  define timeb _timeb
#  define ftime _ftime
# endif
#else
# include <sys/time.h>
#endif  // _WINDOWS

#include <asm/bitsperlong.h>

using namespace XmlRpc;


XmlRpcDispatch::XmlRpcDispatch()
{
  _doClear = false;
  _inWork = false;
}


XmlRpcDispatch::~XmlRpcDispatch()
{
}

// Monitor this source for the specified events and call its event handler
// when the event occurs
void
XmlRpcDispatch::addSource(XmlRpcSource* source, unsigned mask)
{
  //avoid double addition
  for (SourceList::iterator it=_sources.begin(); it!=_sources.end(); ++it)
    if (it->getSource() == source)
    {
      it->getMask()=mask;
      return;
    }

  _sources.push_back(MonitoredSource(source, mask));
}

// Stop monitoring this source. Does not close the source.
void
XmlRpcDispatch::removeSource(XmlRpcSource* source)
{
  for (SourceList::iterator it=_sources.begin(); it!=_sources.end(); ++it)
    if (it->getSource() == source)
    {
      _sources.erase(it);
      break;
    }
}


// Modify the types of events to watch for on this source
void 
XmlRpcDispatch::setSourceEvents(XmlRpcSource* source, unsigned eventMask)
{
  for (SourceList::iterator it=_sources.begin(); it!=_sources.end(); ++it)
    if (it->getSource() == source)
    {
      it->getMask() = eventMask;
      break;
    }
}



// Watch current set of sources and process events
bool
XmlRpcDispatch::work(int32_t msTime)
{
	_doClear = false;
	_inWork = true;
	
	
	// Construct the sets of descriptors we are interested in
	fd_set inFd, outFd, excFd;
	FD_ZERO(&inFd);
	FD_ZERO(&outFd);
	FD_ZERO(&excFd);
	
	int maxFd = -1;     // Not used on windows
	bool dataPending = false;
	SourceList::iterator it;
	for (it=_sources.begin(); it!=_sources.end(); ++it) {
		int fd = it->getSource()->getfd();
		unsigned mask=it->getMask()|it->getSource()->getExtraMask();
		if (mask & ReadableEvent) FD_SET(fd, &inFd);
		if (mask & WritableEvent) FD_SET(fd, &outFd);
		if (mask & Exception)     FD_SET(fd, &excFd);
		if (mask && fd > maxFd)   maxFd = fd;
		if (mask & DataPending)	  dataPending = true;
	}
	
	// Check for events
	int nEvents;
	if (msTime <= 0){
		nEvents = select(maxFd+1, &inFd, &outFd, &excFd, NULL);
	}
	else 
	{
		struct timeval tv;
		if( dataPending )
		{
			//At least one source has data to be immediately processed. Just poll the other sources.
			tv.tv_sec = 0;
			tv.tv_usec = 0;
		}else{
			tv.tv_sec = msTime/1000;
			tv.tv_usec = (msTime%1000)*1000;
		}
		nEvents = select(maxFd+1, &inFd, &outFd, &excFd, &tv);
	}
	
	if (nEvents < 0)
	{
		XmlRpcUtil::error("Error in XmlRpcDispatch::work: error in select (%d).", nEvents);
		_inWork = false;
		return false;
	}

	// Process events
	for (it=_sources.begin(); it != _sources.end(); )
	{
		SourceList::iterator thisIt = it++;
		XmlRpcSource* src = thisIt->getSource();
		int fd = src->getfd();
		unsigned newMask = (unsigned) -1;
		if (fd <= maxFd) {
			// If you select on multiple event types this could be ambiguous
			unsigned mask=src->getExtraMask();
			if ( mask & DataPending )
			{
				newMask&=src->handleEvent(DataPending);
			}else{
				if (FD_ISSET(fd, &inFd)){
					newMask&=src->handleEvent(ReadableEvent);
				}
			}
			if (FD_ISSET(fd, &outFd))
				newMask &= src->handleEvent(WritableEvent);
			if (FD_ISSET(fd, &excFd))
				newMask &= src->handleEvent(Exception);
			
			if ( ! newMask) {
				XmlRpcUtil::log(5, "XmlRpcDispatch::work: erasing src %p", src);
				_sources.erase(thisIt);  // Stop monitoring this one
				if ( ! src->getKeepOpen())
					src->close();
			} else if (newMask != (unsigned) -1) {
				thisIt->getMask() = newMask;
			}
		}
	}
	
	// Check whether to clear all sources
	if (_doClear)
	{
		SourceList closeList = _sources;
		_sources.clear();
		for (SourceList::iterator it=closeList.begin(); it!=closeList.end(); ++it) {
			XmlRpcSource *src = it->getSource();
			src->close();
		}
		
		_doClear = false;
	}
	
	_inWork = false;

    return nEvents > 0;
}


// Exit from work routine. Presumably this will be called from
// one of the source event handlers.
void
XmlRpcDispatch::exit()
{
//  _endTime = 0.0;   // Return from work asap
}

// Clear all sources from the monitored sources list
void
XmlRpcDispatch::clear()
{
  if (_inWork)
    _doClear = true;  // Finish reporting current events before clearing
  else
  {
    SourceList closeList = _sources;
    _sources.clear();
    for (SourceList::iterator it=closeList.begin(); it!=closeList.end(); ++it)
      it->getSource()->close();
  }
}

#define NSEC_PER_SEC      1000000000L
#define NSEC_PER_MILLISEC 1000000L
#define MSEC_PER_SEC      1000L

uint64_t
XmlRpcDispatch::getTime()
{
#ifdef USE_FTIME
  struct timeb	tbuff;

  ftime(&tbuff);
  return static_cast<uint64_t>((tbuff.time * MSEC_PER_SEC) + tbuff.millitm + (tbuff.timezone * 60000));
#else
  struct timespec now;
  clock_gettime(CLOCK_REALTIME, &now);
  return now.tv_sec * MSEC_PER_SEC + now.tv_nsec / NSEC_PER_MILLISEC;
#endif /* USE_FTIME */
}
