import discord
import requests
import os
import asyncio

def get_chuck_quote():
    response = requests.get('https://api.chucknorris.io/jokes/random')
    return response.json().get('value')

async def run_bot(token, channel_id):
    intents = discord.Intents.default()
    intents.guilds = True
    client = discord.Client(intents=intents)

    @client.event
    async def on_ready():
        print(f'Logged in as {client.user}')
        channel = client.get_channel(channel_id)
        if channel is None:
            try:
                channel = await client.fetch_channel(channel_id)
            except Exception as e:
                print(f"Error fetching channel {channel_id}: {e}")
                await client.close()
                return

        quote = get_chuck_quote()
        await channel.send(quote)
        await client.close()

    await client.start(token)

def lambda_handler(event, context):
    token = os.environ.get('DISCORD_TOKEN')
    channel_id_str = os.environ.get('DISCORD_CHANNEL_ID')
    
    if not token or not channel_id_str:
        error_msg = "Missing DISCORD_TOKEN or DISCORD_CHANNEL_ID environment variable."
        print(error_msg)
        return {"statusCode": 500, "body": error_msg}

    try:
        channel_id = int(channel_id_str)
    except ValueError:
        error_msg = "DISCORD_CHANNEL_ID must be an integer."
        print(error_msg)
        return {"statusCode": 500, "body": error_msg}

    try:
        asyncio.run(run_bot(token, channel_id))
    except Exception as e:
        error_msg = f"Error running discord client: {e}"
        print(error_msg)
        return {"statusCode": 500, "body": error_msg}

    return {"statusCode": 200, "body": "Quote sent successfully."}
