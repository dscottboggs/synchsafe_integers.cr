require "./spec_helper"

describe "synchsafe Int32" do
  it "works" do
    255.synchsafe_encode.should eq 383
    383.synchsafe_decode.should eq 255
  end
  it "effectively provides a ceiling to the maximum value" do
    Int32::SYNCH_SAFE_FROM_MAX.should eq 2139062143
    Int32::SYNCH_SAFE_FROM_MAX.synchsafe_decode.should eq 268435455
    expect_raises OverflowError do
      (Int32::SYNCH_SAFE_TO_MAX + 1).synchsafe_encode
    end
  end
end
