#ifndef __GDT_H_DEFINED
#define __GDT_H_DEFINED
#include "types.h"



class GDT
{
   
   public:
    ///each segment is a 64 bit bulk.
   class Segment
   {
       public:
        uint16_t limit_lo;
        uint16_t base_lo;
        uint8_t  base_hi;
        uint8_t type;
        uint8_t limit_hi;
        uint8_t base_vhi;
   
        Segment(uint32_t base, uint32_t limit, uint8_t type);
        uint32_t Base();
        uint32_t Limit();
   
   
   }__attribute__((packed));



    Segment nullSegmentSelector;
    Segment unusedSegmentSelector;
    Segment codeSegmentSelector;
    Segment dataSegmentSelector;

    GDT();
    ~GDT();

    uint16_t CodeSegmentSelector();
    uint16_t DataSegmentSelector();


};


#endif