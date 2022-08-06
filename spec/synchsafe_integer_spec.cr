require "./spec_helper"

describe "synchsafe Int32" do
  it "works i32" do
    255.synchsafe_encode.should eq 383
    383.synchsafe_decode.should eq 255
  end
  it "works u32" do
    255_u32.synchsafe_encode.should eq 383_u32
    383_u32.synchsafe_decode.should eq 255_u32
  end
  it "works i16" do
    255_i16.synchsafe_encode.should eq 383_i16
    383_i16.synchsafe_decode.should eq 255_i16
  end
  it "works u16" do
    255_u16.synchsafe_encode.should eq 383_u16
    383_u16.synchsafe_decode.should eq 255_u16
  end
  it "effectively provides a ceiling to the maximum value" do
    Int32::SYNCH_SAFE_FROM_MAX.should eq 2139062143
    Int32::SYNCH_SAFE_FROM_MAX.synchsafe_decode.should eq 268435455
    expect_raises OverflowError do
      (Int32::SYNCH_SAFE_TO_MAX + 1).synchsafe_encode
    end
  end
end
