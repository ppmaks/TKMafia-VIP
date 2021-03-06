package com.company.assembleegameclient.ui.components {
import com.company.ui.SimpleText;

import flash.display.Sprite;

import kabam.lib.util.TimeWriter;

public class TimerDisplay extends Sprite {


    public function TimerDisplay(textField:SimpleText) {
        this.stringifier = new TimeWriter();
        super();
        this.initTextField(textField);
    }
    private var _textField:SimpleText;
    private var stringifier:TimeWriter;

    public function update(time:Number):void {
        this._textField.text = this.stringifier.parseTime(time);
        this._textField.updateMetrics();
    }

    private function initTextField(textField:SimpleText):void {
        addChild(this._textField = textField);
    }
}
}
