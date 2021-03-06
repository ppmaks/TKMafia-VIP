package kabam.rotmg.fame.view {
import flash.display.BitmapData;

import kabam.rotmg.assets.services.CharacterFactory;
import kabam.rotmg.core.signals.GotoPreviousScreenSignal;
import kabam.rotmg.core.signals.SetScreenSignal;
import kabam.rotmg.death.model.DeathModel;
import kabam.rotmg.fame.model.FameModel;
import kabam.rotmg.fame.service.RequestCharacterFameTask;
import kabam.rotmg.legends.view.LegendsView;
import kabam.rotmg.messaging.impl.incoming.Death;

import robotlegs.bender.bundles.mvcs.Mediator;

public class FameMediator extends Mediator {


    public function FameMediator() {
        super();
    }
    [Inject]
    public var view:FameView;
    [Inject]
    public var fameModel:FameModel;
    [Inject]
    public var deathModel:DeathModel;
    [Inject]
    public var setScreen:SetScreenSignal;
    [Inject]
    public var gotoPrevious:GotoPreviousScreenSignal;
    [Inject]
    public var task:RequestCharacterFameTask;
    [Inject]
    public var factory:CharacterFactory;
    private var isFreshDeath:Boolean;
    private var death:Death;

    override public function initialize():void {
        this.view.closed.add(this.onClosed);
        this.setViewDataFromDeath();
        this.requestFameData();
    }

    override public function destroy():void {
        this.view.closed.remove(this.onClosed);
        this.view.clearBackground();
        this.death && this.death.disposeBackground();
        this.task.finished.removeAll();
    }

    private function setViewDataFromDeath():void {
        this.isFreshDeath = this.deathModel.getIsDeathViewPending();
        this.view.setIsAnimation(this.isFreshDeath);
        this.death = this.deathModel.getLastDeath();
        if (this.death && this.death.background) {
            this.view.setBackground(this.death.background);
        }
    }

    private function requestFameData():void {
        this.task.accountId = this.fameModel.accountId;
        this.task.charId = this.fameModel.characterId;
        this.task.finished.addOnce(this.onFameResponse);
        this.task.start();
    }

    private function onFameResponse(task:RequestCharacterFameTask, isOK:Boolean, error:String = ""):void {
        var icon:BitmapData = this.makeIcon();
        this.view.setCharacterInfo(task.name, task.level, task.type);
        this.view.setDeathInfo(task.deathDate, task.killer);
        this.view.setIcon(icon);
        this.view.setScore(task.totalFame, task.xml);
    }

    private function makeIcon():BitmapData {
        return this.makeNormalTexture();
    }

    private function makeNormalTexture():BitmapData {
        return this.factory.makeIcon(this.task.template, 250, this.task.texture1, this.task.texture2);
    }

    private function onClosed():void {
        if (this.isFreshDeath) {
            this.setScreen.dispatch(new LegendsView());
        } else {
            this.gotoPrevious.dispatch();
        }
    }
}
}
