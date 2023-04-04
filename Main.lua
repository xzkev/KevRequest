local Players = game:GetService('Players');
local HttpService = game:GetService('HttpService');
local Request = syn and syn.request or http and http.request or http_request;

local KevRequest = {};
KevRequest.__index = KevRequest;

KevRequest.new = function()
	local self = setmetatable({}, KevRequest);

	self.Queue = {};
	self.RequestBody = {};

	self.MessageID = '';
	self.WebhookID = '';
	self.DiscordID = '';
	
	self.MessageURL = '';
	self.WebhookURL = '';
	self.RequestURL = '';

	return self;
end;

function KevRequest:FormatPing()
	return '<@' ..  self.DiscordID .. '>';
end;

function KevRequest:Set(Index, Value)
	self[Index] = Value;
end;

function KevRequest:GetMetaTable()
	return self;
end;

function KevRequest:GET()
	return Request({
		Url = self.RequestURL;
		Method = 'GET';
	}).Body;
end;

function KevRequest:POST()
	local Split = self.WebhookURL:split('https://discordapp.com/api/')[2];
	local WebhookURL = 'https://discord.com/api/v10/'..Split;

	local Post = HttpService:JSONDecode(Request({
		Headers = {['Content-Type'] = 'application/json'};
		Body = HttpService:JSONEncode(self.RequestBody);
		Url = WebhookURL .. '?wait=true';
		Method = 'POST';
	}).Body);
	
	self:Set('MessageID', Post.id);
	self:Set('WebhookID', Post['webhook_id']);
	
	return Post;
end;

function KevRequest:PATCH()
	local Split = self.WebhookURL:split('https://discordapp.com/api/')[2];
	local WebhookURL = 'https://discord.com/api/v10/'..Split;
	
	local Patch = HttpService:JSONDecode(Request({
		Url = WebhookURL .. '/message/' .. self.MessageID;
		Headers = {['Content-Type'] = 'application/json'};
		Body = HttpService:JSONEncode(self.RequestBody);
		Method = 'PATCH';
	}).Body);
	
	self:Set('MessageID', Patch.id);
	self:Set('WebhookID', Patch['webhook_id']);
	
	return Patch;
end;

return KevRequest;
