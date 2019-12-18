////this code is part of https://www.youtube.com/watch?v=pfWjteMpcxE&t=12s
//// must be change after I really understand how Global Descriptor table 
///  works .


#include "hardware/x86/GDT.h"




GlobalDescriptorTable::GlobalDescriptorTable():
nullSegmentSelector(0,0,0),
unusedSegmentSelector(0,0,0),
codeSegmentSelector(0,64*1024*1024,0x9A),
dataSegmentSelector(0,64*1024*1024,0x92)
{
    u32 iPtr[2];
    iPtr[0] = (u32)this;
    iPtr[1] = sizeof(GlobalDescriptorTable)<<16;

    asm volatile("lgdt (%0)": :"p"(((u8*)iPtr)+2));
}
GlobalDescriptorTable::~GlobalDescriptorTable(){}

u16 GlobalDescriptorTable::CodeSegmentSelector()
{
     return (u8*)&dataSegmentSelector - (u8*)this;
}
u16 GlobalDescriptorTable::DataSegmentSelector()
{
     return (u8*)&codeSegmentSelector - (u8*)this;
}


GlobalDescriptorTable::SegmentDescriptor::SegmentDescriptor(u32 base, u32 limit, u8 type)
{
   u8* target = (u8*)this;
   if(limit <= 65536)
   {
       target[6]= 0x40;
   }   
   else
   {
       if((limit & 0xfff) != 0xfff)
          limit = (limit>>12)-1;
       else
          limit = (limit>>12);
       target[6]= 0xc0;
   }
      target[0] = limit & 0xFF;
      target[1] = (limit >> 8)  & 0xFF;
      target[6] |= (limit >> 16) & 0xF;
 
      target[2] = base & 0xff;
      target[3] = (base >> 8)  & 0xff;
      target[4] = (base >> 16) & 0xF;
      target[7] = (base >> 24) &0xfF;
      target[5] = type;
    
}
u32  GlobalDescriptorTable::SegmentDescriptor::SegmentDescriptor::Base()
{
    u8* target = (u8*)this;
    u32 result = target[7];
    result = (result << 8) + target[4];
    result = (result << 8) + target[3];
    result = (result << 8) + target[2];
    return result;
}
u32  GlobalDescriptorTable::SegmentDescriptor::SegmentDescriptor::Limit()
{
    u8* target = (u8*)this;
    u32 result = target[6] & 0xF;
    result = (result << 8) + target[1];
    result = (result << 8) + target[0];
    if((target[6]&0xc0)==0xc0)
        result = (result << 12)  | 0xFFF;
    return result;
}